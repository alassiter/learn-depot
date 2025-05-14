require "test_helper"

class ProductTest < ActiveSupport::TestCase
  fixtures :products
  test "product is valid with valid attributes" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image].any?
  end

  test "product price must be positive" do
    product = Product.new(title: products(:pragprog).title + "1", description: "Test Description")
    product.image.attach(io: File.open("test/fixtures/files/lorem.jpg"), filename: "lorem.jpg", content_type: "image/jpg")
    product.price = -1
    assert product.invalid?
    assert_equal [ "must be greater than or equal to 0.01" ], product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal [ "must be greater than or equal to 0.01" ], product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  def new_product(image_url, content_type: "image/jpeg")
    product = Product.new(title: products(:pragprog).title + "1", description: "yyy", price: 1)
    product.image.attach(io: File.open(image_url), filename: File.basename(image_url), content_type:)
    product
  end

  test "image url" do
    product = new_product("test/fixtures/files/lorem.jpg")
    assert product.valid?, "image/jpg or image/jpeg must be valid"

    # product2 = new_product("test/fixtures/files/logo.svg", content_type: "image/svg+xml")
    # assert product2.invalid?, "image/svg+xml must be invalid"
  end

  test "product is not valid without a unique title - i18n" do
    product = Product.new(title:       products(:pragprog).title,
                          description: "yyy",
                          price:       1)

    product.image.attach(io: File.open("test/fixtures/files/lorem.jpg"),
                        filename: "lorem.jpg", content_type: "image/jpeg")

    assert product.invalid?
    assert_equal [ I18n.translate("errors.messages.taken") ],
                 product.errors[:title]
  end
end
