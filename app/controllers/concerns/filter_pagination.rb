# Common behavior for filtering and ppagination of results in API and UI controllers
module FilterPagination
  private

  def filter_params
    params.fetch(:q,{}).permit!
  end

  def pagination_params
    params.fetch(:page,{}).permit(:number,:size)
  end

  def pagination_number
    pagination_params[:number]
  end

  def pagination_size
    pagination_params[:size]
  end

  def pagination_link_params(records)
    first_page = pagination_params.merge(number: 1)
    first_page_params = filter_params.merge(page: first_page).to_hash

    links = { 
      first: first_page_params
    }

    unless records.first_page?
      previous_page = pagination_params.merge(number: records.prev_page).to_hash
      links[:previous] = filter_params.merge(page: previous_page).to_hash
    end

    unless records.last_page?
      next_page = pagination_params.merge(number: records.next_page).to_hash
      links[:next] = filter_params.merge(page: next_page).to_hash
    end

    links
  end
end
