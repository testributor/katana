class GithubPageManager
  #https://developer.github.com/guides/traversing-with-pagination/

  def initialize(last_response)
    @last_response = last_response
  end

  def all_pages_number
    if last_page.nil?
      current_page_number
    else
      last_page
    end
  end

  def last_page
    page_of(@last_response.rels[:last])
  end

  def previous_page_number
    page_of(@last_response.rels[:prev])
  end

  def next_page_number
    page_of(@last_response.rels[:next])
  end

  def current_page_number
    page = if next_page_number.present?
      next_page_number.to_i - 1
    elsif previous_page_number.present?
      previous_page_number.to_i + 1
    end

    page.nil? ? 1 : page
  end

  private

  def page_of(uri)
    return nil unless uri.try(:href)
    params = CGI::parse(URI::parse(uri.href).query)

    params["page"].first.to_i if params["page"].present?
  end
end
