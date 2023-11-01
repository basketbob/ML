// 2. Создать базу данных
use products

// 3. Вставить 4 документа по товарам на сайте.
db.products.insertMany([
  {name: 'snickers', category: 'chocolate', price: 59, count: 123 },
  {name: 'mars', category: 'chocolate', price: 59, count: 1234 },
  {name: 'potato', category: 'veg', price: 25, count: 456 },
  {name: 'tomato', category: 'veg', price: 201, count: 789 },
]);
db.products.find();

// 4. Рассчитать остаточную стоимость товаров в каждой категории (сумма цены, умноженной на остаток)
db.products.aggregate(
  {$group: {_id: '$category', sumprice: {$sum: { $multiply: [ "$price", "$count" ] }}}}
)

// 5. Уменьшить количество товара на 1
db.products.updateMany({}, {$inc:{count: -1}})

// 6. Вывести top-2 самых дорогих товара
db.products.find().sort({price: -1}).limit(2)