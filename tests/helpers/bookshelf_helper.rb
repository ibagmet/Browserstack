require 'httparty'
require 'json'

module BookshelfHelper

  # returns bookshelf auth hash if successful. Otherwise raise error.
  def login_bookshelf_user(email, password)
    url = "#{bookshelf_api_base_url}/login_account"
    body = { email: email, password: password }.to_json
    response = HTTParty.post(url,
      verify: false, # don't verify ssl cert
      body: body,
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    )

    result = JSON.parse(response.body)

    if result['hash']
      return result['hash']
    else
      raise "Error logging in to bookshelf:\nURL: #{url}\nBody:\n#{body}\nResponse:\n#{response.body}"
    end
  end

  def remove_book_from_bookshelf_account(auth_token, book_id)
    url = "#{bookshelf_api_base_url}/books/#{book_id}?t=#{auth_token}"
    response = HTTParty.delete(url,
      verify: false, # don't verify ssl cert
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    )

    result = JSON.parse(response.body)

    if result['success']
      return result['success']
    else
      raise "Error removing book from bookshelf account:\nURL: #{url}\nResponse:\n#{response.body}"
    end
  end

  # does the given bookshelf account contain a book with the given book_id?
  def bookshelf_account_contains_book?(auth_token, book_id)
    url = "#{bookshelf_api_base_url}/get_ebooks?t=#{auth_token}"
    
    response = HTTParty.get(url,
      verify: false, # don't verify ssl cert
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    )

    result = JSON.parse(response.body)

    if result['ebooks']
      !!result['ebooks'].detect{|ebook| ebook['id'] == book_id.to_i}
    else
      raise "Error getting book list from bookshelf:\nURL: #{url}\n\nResponse:\n#{response.body}"
    end
  end
end