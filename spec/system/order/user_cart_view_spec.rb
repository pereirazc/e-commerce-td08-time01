require 'rails_helper'

describe 'User enters cart page' do
  it 'and sees cart items' do
    user = create(:user)
    user_2 = create(:user, name: 'Jaime', email: 'jaime@meuemail.com')
    product_1 = create(:product, name: 'Caneca', status: 'on_shelf').set_price(11.99)
    product_2 = create(:product, name: 'Garrafa', status: 'on_shelf').set_price(4.99)
    product_3 = create(:product, name: 'Jarra', status: 'on_shelf').set_price(15.99)
    product_4 = create(:product, name: 'Pote', status: 'draft').set_price(2.99)
    create(:cart_item, product: product_1, quantity: 3, user: user)
    create(:cart_item, product: product_2, quantity: 7, user: user)
    create(:cart_item, product: product_3, quantity: 5, user: user_2)

    login_as(user, scope: :user)
    visit root_path
    click_on "Meu Carrinho"
    
    expect(page).to have_content "Produto Quantidade Preço Quantidade X Preço"
    expect(page).to have_content "Caneca 3 R$ 11,99 R$ 35,97"
    expect(page).to have_content "Garrafa 7 R$ 4,99 R$ 34,93"
    expect(page).not_to have_content "Jarra 5 R$ 15,99 R$ 79,95"
    expect(page).not_to have_content "Pote 7 R$ 2,99 R$ 20,93"
  end

  it 'and there are no cart items' do
    user = create(:user)
    user_2 = create(:user, name: 'Jaime', email: 'jaime@meuemail.com')
    product_1 = create(:product, name: 'Jarra').set_price(15.99)
    product_2 = create(:product, name: 'Pote').set_price(2.99)
    create(:cart_item, product: product_1, quantity: 7, user: user_2)
    create(:cart_item, product: product_2, quantity: 5, user: user_2)

    login_as(user, scope: :user)
    visit root_path
    click_on "Meu Carrinho"
    
    expect(page).to have_content "Adicione um produto ao carrinho!"
    expect(page).not_to have_content "Jarra 5 R$ 15,99"
    expect(page).not_to have_content "Pote 7 R$ 2,99"
  end
  
  it 'after adding a product' do
    user = create(:user)
    product_1 = create(:product, name: 'Caneca', status: 'on_shelf').set_price(11.99)
    product_2 = create(:product, name: 'Garrafa', status: 'on_shelf').set_price(4.99)
    product_3 = create(:product, name: 'Jarra', status: 'on_shelf').set_price(15.99)
    create(:cart_item, product: product_1, user:  user)
    create(:cart_item, product: product_2, user:  user)

    login_as(user, scope: :user)
    visit root_path
    click_on "Jarra"
    fill_in "Quantidade", with: '5'
    click_on "Adicionar ao carrinho"
    click_on "Meu Carrinho"
    
    expect(current_path).to eq user_cart_items_path(user)
    expect(page).to have_content "Caneca"
    expect(page).to have_content "Garrafa"
    expect(page).to have_content "Jarra"
  end

  it 'and withdraws an item' do
    user = create(:user)
    product_1 = create(:product, name: 'Caneca', status: 'on_shelf').set_price(11.99)
    product_2 = create(:product, name: 'Garrafa', status: 'on_shelf').set_price(4.99)
    product_3 = create(:product, name: 'Jarra', status: 'on_shelf').set_price(15.99)
    create(:cart_item, product: product_1, user: user)
    create(:cart_item, product: product_2, user: user)
    create(:cart_item, product: product_3, user: user)

    login_as(user, scope: :user)
    visit root_path
    click_on "Meu Carrinho"
    within('tbody') do
      first('tr').click_on("Retirar")
    end
    
    expect(page).to have_content "Produto retirado: Caneca."
    within('tbody') do
      expect(page).not_to have_content "Caneca"
    end
    expect(page).to have_content "Garrafa"
    expect(page).to have_content "Jarra"
  end

  it 'and enters product page through cart link' do
    user = create(:user)
    product = create(:product, name: 'Caneca', status: 'on_shelf').set_price(8.44)
    create(:cart_item, product: product, user: user)

    login_as(user, scope: :user)
    visit root_path
    click_on "Meu Carrinho"
    within('tbody') do
      first('tr').click_on("Caneca")
    end
    
    expect(page).to have_text 'Caneca'
    expect(page).to have_text 'TOC & Ex-TOC'
    expect(page).to have_text 'Caneca em cerâmica com desenho de uma flecha do cupido'
    expect(page).to have_text 'R$ 8,44' 
    expect(current_path).to eq product_path(product)
    expect(page).to have_text 'Caneca'
  end

  context 'and goes back to previous page' do
    it 'which was a product detail page' do
      user = create(:user)
      product = create(:product, name: 'Caneca', status: 'on_shelf').set_price(8.44)
      create(:cart_item, product: product, user: user)
  
      login_as(user, scope: :user)
      visit root_path
      click_on "Caneca"
      click_on "Meu Carrinho"
      click_on "Voltar"

      expect(current_path).to eq product_path(product)
      expect(page).to have_text 'Caneca'
    end

    it 'which was the orders index page' do
      user = create(:user)
  
      login_as(user, scope: :user)
      visit root_path
      click_on "Meus Pedidos"
      click_on "Meu Carrinho"
      click_on "Voltar"

      expect(current_path).to eq user_orders_path(user)
      expect(page).to have_text 'Você ainda não possui nenhum pedido.'
    end

    it 'unsuccessfully, as it was the generate order page and the cart had been emptied' do
      user = create(:user)
      product = create(:product, name: 'Caneca', status: 'on_shelf').set_price(8.44)
      create(:cart_item, product: product, user: user)
  
      login_as(user, scope: :user)
      visit root_path
      click_on "Meu Carrinho"
      click_on "Finalizar Pedido"
      click_on "Voltar"
      click_on "Retirar"
      click_on "Voltar"

      expect(current_path).to eq user_cart_items_path(user)
      expect(page).to have_text 'Adicione um produto ao carrinho!'
    end
  end
end