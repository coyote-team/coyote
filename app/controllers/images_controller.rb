class ImagesController < ApplicationController
  before_action :set_image, only: %i[show edit update destroy toggle]
  before_action :clear_search, only: %i[index]
  before_action :set_users, only: %i[index show], unless: -> { request.xhr? }

  before_action :users, only: %i[create]

  helper_method :image, :contexts, :tag_list, :users

  respond_to :html

  def index
    authorize(Image)

    @status_ids = [2]
    @status_ids = params[:status_ids] if params[:status_ids]

    if params[:canonical_id].present? 
      self.image = current_organization.images.find_by(canonical_id: params[:canonical_id]) # for ajax
    else
      if params["updated_at"].present?
        params["q"] = {} 
        params["q"]["s"] = "updated_at desc"
        params["q"]["updated_at_gteq"] = Time.parse(params["updated_at"]) if params["updated_at"].present?
      end

      @search_cache_key = params["q"]

      if search_params
        search_params["title_cont_all"] = search_params["title_cont_all"].split(" ") if search_params["title_cont_all"].present?
        search_params["descriptions_text_cont_all"] = search_params["descriptions_text_cont_all"].split(" ") if search_params["descriptions_text_cont_all"].present?
        search_params["tags_name_cont_all"] = search_params["tags_name_cont_all"].split(" ") if search_params["tags_name_cont_all"].present?
      end

      @q = current_organization.images.ransack(search_params)

      # tag filtering does not cooperate with ransack but can paginate
      if params[:tag].present? 
        @images = current_organization.images.tagged_with(params[:tag]).page(params[:page]) 
      else
        @images = @q.result(distinct: true).page(params[:page]) 
      end

      if request.format.html?
        # for tagcloud
        @tags = Rails.cache.fetch('tags', expires_in: 15.minutes) do
          Image.tag_counts_on(:tags)
        end
      end
    end
  end

  # GET /images/1
  def show
    authorize(image)
    @status_ids = [2]
    @status_ids = params[:status_ids] if params[:status_ids]

    if request.format.html?
      @previous_image = Image.where("id < ?", image.id).first
      @next_image = Image.where("id > ?", image.id).first
    end
  end

  # GET /images/new
  def new
    authorize Image
    self.image = current_organization.images.new
  end

  # GET /images/1/edit
  def edit
    authorize(image)
  end

  # POST /images
  def create
    authorize Image

    image_params[:context] = current_organization.contexts.find_by(id: image_params.delete(:context_id))

    self.image = current_organization.images.create(image_params)

    if image.valid?
      # TODO: make these use Rails responders instead of format conditionals
      if request.format.html?
        logger.info "Succesfully created #{image}"
        redirect_to [current_organization,image], notice: 'Image was successfully created.'
      else
        render json: image
      end
    else
      logger.warn "Unabled to create image: '#{image.errors.full_messages.to_sentence}'"

      if request.format.html?
        render :new
      else
        render json: { errors: image.errors.full_messages }
      end
    end
  end

  def update
    authorize(image)

    if image.update(image_params)
      if request.format.html?
        redirect_to [current_organization,image], notice: 'Image was successfully updated.'
      else
        render image
      end
    else
      if request.format.html?
        render :edit
      else
        render json: { errors: image.errors.full_messages }
      end
    end
  end

  # DELETE /images/1
  def destroy
    authorize(image)
    image.destroy
    redirect_to organization_images_url(current_organization), notice: 'Image was successfully destroyed.'
  end

  def autocomplete_tags
    @tags = ActsAsTaggableOn::Tag.
      where("name LIKE ?", "#{params[:q]}%").
      order(:name)

    respond_to do |format|
      format.json { render json: @tags.map{|t| {id: t.name, name: t.name}}}
    end
  end

  def export 
    send_data Image.all.to_csv
  end

  def import
    begin
      Image.import(params[:file])
      redirect_to root_path, {notice: "Images imported."}
    rescue => e
      logger.error e.message
      redirect_to root_path, {alert: "Images failed to import. " + e.message}
    end
  end

  def titles
    canonical_ids = params["canonical_ids"]

    #TODO try to read each image in cache and if not available, then bulk grab
    ids_titles = Rails.cache.fetch(canonical_ids, expires_in: 1.minute) do
      require 'multi_json'
      require 'open-uri'

      ids_titles = {}

      #prep url
      url = "https://mcachicago.org/api/v1/attachment_images/?"
      canonical_ids.each do |i|
        url += "ids[]=" + i + "&"
      end

      Rails.logger.info "grabbing images json at #{url}"

      begin
        content = open(url, { "Content-Type" => "application/json", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, read_timeout: 10}).read
        begin
          images_received = JSON.parse(content)

          #match ids, add titles to image cache, and set titles
          canonical_ids.each do |id|
            i = images_received.find { |ir| ir["id"].to_s == id.to_s}
            if i
              title = Rails.cache.fetch([id, 'title'].hash, expires_in: 1.minute) do
                i["title"]
              end
              ids_titles[id] = title
            end
          end
        rescue StandardError => e
          Rails.logger.error "JSON parsing exception"
          Rails.logger.error e
          length = 0
        end
      rescue OpenURI::HTTPError => error
        response = error.io
        Rails.logger.error response.string
        length = 0
      end
      ids_titles
    end

    render json: ids_titles
  end

  def toggle
    image.toggle!(params[:column].to_sym)
    render nothing: true
  end

  private

  attr_accessor :image, :users

  def contexts
    @contexts ||= current_organization.contexts
  end

  def tag_list
    @tag_list ||= ActsAsTaggableOn::Tag.most_used(30)
  end

  def set_users
    self.users = current_organization.users
  end

  def set_image
    self.image = current_user.images.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:path,:context_id,:canonical_id,:organization_id,:title,:priority,:page_urls,tag_list: [],page_urls: [])
  end

  def search_params
    params[:q]
  end

  def clear_search
    if params[:search_cancel]
      params.delete(:search_cancel)
      if(!search_params.nil?)
        search_params.each do |key, param|
          search_params[key] = nil
        end
      end
    end
  end
end
