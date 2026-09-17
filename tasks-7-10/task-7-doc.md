# Задание 7. Проектирование схем коллекций для шардирования данных
## Коллекция orders
Схема:
```json
id: String
client_id: String
created_at: Number;
items: [{
    "product_id": String
    "price": Number
}]
status: String
total_price: Number
location: {
    lat: String
    long: String
}
```

Основные операции:
- Быстрое создание заказов с одновременным списанием остатков.
- Поиск истории заказов конкретного пользователя.
- Отображение статуса заказа.

### Шардирование
Шард-ключ: `client_id: hashed`

Стратегия: range based sharding

Обоснование: Подходит, т.к. главная операция — история заказов пользователя. Равномерное распределение по client_id роутит запрос на одну шарду, все заказы клиента лежат вместе.

## Коллекция products
Схема:
```json
    id: String
    title: String
    category_id: String
    price: Number
    count: Number
    appearance: {
        color: String
        size: String
    } 
```
Основные операции:
- Частые обновления остатков при покупках.
- Поиск товаров по категориям и фильтрация по диапазону цен.
- Описание товара на странице продукта.

### Шардирование

Шард-ключ: `id: hashed`

Стратегия: range based sharding

Обоснование: остатки обновляются точечно по id — hashed даёт равномерную запись и таргетированный апдейт/чтение карточки товара по id (одна шарда).
Еще не плохо было бы category_id, но их не так много. 


## Коллекция carts
Схема:
```json
    {
        id: String
        user_id: String
        session_id: String
        owner_id: String # (составной, если есть user_id то берет его иначе session_id)
        items: { 
            product_id: String
            quantity: Number
        }
        status: String
        created_at: Number
        updated_at: Number
        expires_at: Number
    }
```

Основные операции:
- Создание корзины, когда заходит гость или новый пользователь.
- Получение текущей корзины по фильтру { session_id, status:"active" } или { user_id, status:"active" }.
- Добавление или замена товара в корзине.
- Удаление товара из корзины.
- Слияние гостевой корзины в пользовательскую, если пользователь залогинится:
- прочитать гостевую { session_id, status:"active" };
- добавить её items в корзину { user_id, status:"active" };
- отметить гостевую как abandoned.
- Отметка корзины как заказанной.

### Шардирование

Шард-ключ: `owner_id: hashed`

Стратегия: range based sharding

Обоснование: hashed равномерно распределяет запись по шардам. Корзины часто создаются, меняются и удаляются (по TTL), поэтому нагрузка на запись большая — hashed не даёт всей этой нагрузке скапливаться на одной шарде