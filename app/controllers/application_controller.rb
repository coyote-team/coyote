class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  acts_as_token_authentication_handler_for User, if: lambda { |controller| controller.request.format.json? }

  analytical 

  enable_authorization do |exception|
    redirect_to root_url, :alert => exception.message
  end unless :devise_controller?

  def search_params
    params[:q]
  end

  def clear_search_index
    if params[:search_cancel]
      params.delete(:search_cancel)
      if(!search_params.nil?)
        search_params.each do |key, param|
          search_params[key] = nil
        end
      end
    end
  end

  def get_image_title(image)
    image.title
  end

  def get_images_titles(images)
    Rails.cache.fetch('images_titles', expires_in: 2.minutes) do
      require 'multi_json'
      require 'open-uri'

      #prep url 
      url = "https://cms.mcachicago.org/api/v1/attachment_images/?"
      images.each do |i| 
        if i.website.url.include?("mcachicago") 
          url += "ids[]=" + i.canonical_id + "&"
        end
      end

      #request 
      Rails.logger.info "grabbing image json at #{url}"
      begin
        content = open(url, { "Content-Type" => "application/json", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
      rescue OpenURI::HTTPError => error
        response = error.io
        Rails.logger.error response.string
        length = 0
      end

      #parse 
      begin 
        images_received = JSON.parse(content)
      rescue Exception => e
        Rails.logger.error "JSON parsing exception"
        Rails.logger.error e
        length = 0
      end

      #match ids, add titles to image cache, and set titles
      images_titles = {}
      images.each do |image|
        i = images_received.find{|i| i["id"] == image.canonical_id}
        puts i
        if i
          title = Rails.cache.fetch([image, 'title'].hash, expires_in: 1.minute) do
            i["title"]
          end
          images_titles[image.id] = title
        end
      end

      images_titles
    end
  end

  protected
  def admin
    redirect_to(root_url) unless current_user and current_user.admin?
  end

  def users
    redirect_to(root_url) if current_user.nil?
  end
end
