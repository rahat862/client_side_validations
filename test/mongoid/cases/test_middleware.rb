require 'middleware/cases/helper'

class ClientSideValidationsMongoidMiddlewareTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def teardown
    Book.delete_all
  end

  def app
    app = Proc.new { |env| [200, {}, ['success']] }
    ClientSideValidations::Middleware.new(app)
  end

  def test_uniqueness_when_resource_exists
    Book.create(:author_email => 'book@test.com')
    get '/validators/uniqueness.json', { 'book[author_email]' => 'book@test.com' }

    assert_equal 'false', last_response.body
  end

  def test_uniqueness_when_resource_does_not_exist
    get '/validators/uniqueness.json', { 'book[author_email]' => 'book@test.com' }

    assert_equal 'true', last_response.body
  end

  def test_uniqueness_when_id_is_given
    book = Book.create(:author_email => 'book@test.com')
    get '/validators/uniqueness.json', { 'book[author_email]' => 'book@test.com', 'id' => book.id }

    assert_equal 'true', last_response.body
  end

  def test_uniqueness_when_scope_is_given
    Book.create(:author_email => 'book@test.com', :age => 25)
    get '/validators/uniqueness.json', { 'book[author_email]' => 'book@test.com', 'scope' => { 'age' => 30 } }

    assert_equal 'true', last_response.body
  end

  def test_uniqueness_when_multiple_scopes_are_given
    Book.create(:author_email => 'book@test.com', :age => 30, :author_name => 'Brian')
    get '/validators/uniqueness.json', { 'book[author_email]' => 'book@test.com', 'scope' => { 'age' => 30, 'author_name' => 'Robert' } }

    assert_equal 'true', last_response.body
  end

  def test_uniqueness_when_case_insensitive
    Book.create(:author_name => 'Brian')
    get '/validators/uniqueness.json', { 'book[author_name]' => 'BRIAN', 'case_sensitive' => false }

    assert_equal 'false', last_response.body
  end
end
