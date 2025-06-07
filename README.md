# social_network_system_design
System Design социальной сети для курса по System Design

# Функциональные требования
1. Лента новостей (посты других пользователей), сортируем по времени (первыми - более свежие)
2. Аутентификация, авторизация пользователей
3. Можно оценивать и комментировать посты других пользователей
4. Можно подписываться на других пользователей
5. Поиск популярных мест, просмотр постов с этих мест

# Нефункциональные требования
1. DAU = 10 000 000
2. В среднем запросов в день - на чтение 20. На запись - создание постов - не более 3 постов в день в среднем.
3. Каждый пользователь ищет в среднем 5 мест для путешествия в день.
4. Каждый пользователь в среднем оставляет 5 комментариев в день. Читаем 30 самых свежих комментариев.
5. Аудитория - страны СНГ.
6. Используем мобильное приложение и браузер.
7. Сезонности: может возрастать нагрузка на праздники/выходные.
8. Условия хранения данных: всегда.
9. Лимиты: 
   1. максимальное количество подписчиков - 1 000 000 подписчиков.
   2. не более 1000 комментариев к одному посту
   3. не более 5 фото к каждому посту
   4. размер комментария не более 100 символов
   5. размер текста в посте - не более 150 символов
10. Лента: подгружаем последние 20 постов единовременно.
11. Реакции: пользователь ставит не более 20 реакций (лайки/дизлайки) в день.
12. Временные ограничения: лента может обновляться не сразу. Допустима задержка не более 2 секунд.
13. Доступность приложения: за год не более 4 часов простоя. (99.95%)
14. Поиск постов: по строке.

# Расчеты

## Таблицы

```
posts (400b):
post_id uuid 8b
description string < 2b * 150 = 300b
owner_id uuid 8b
photo_id string 100b
place_id uuid 8b
likes int 8b
```
```
comments(250b):
comment_id uuid 8b
text string 2b * 100 = 200b
owner_id uuid 8b
```
```
reactions(20b):
user_id uuid 8b
post_id uuid 8b
is_like 1b
```

## RPS

### Посты
read: 10 000 000 * 20 / 86400 ~ 2000
write: 10 000 000 * 3 / 86400 ~ 300

### Комментарии
read: 10 000 000 * 30 / 86400 ~ 3000
write: 10 000 000 * 5 / 86400 ~ 500

### Реакции
10 000 000 * 20 / 86400 ~ 2000

## traffic

### Посты
read:
2000 * 400b = 800000b/s ~ 800 Kb/s

write:
300 * 400b = 1200 b/s = 1.2Kb/s

### Комментарии
read:
3000 * 250b = 750000 b/s ~ 750 Kb/s

write:
500 * 250b = 125000 b/s ~ 125 Kb/s

### Реакции
2000 * 20b = 40000 b/s ~ 40 Kb/s

# Storage
Расчеты на 1 год:

## Capacity
### Посты
800Kb/s * 86400 * 365 ~ 800 * 100 000 * 400 Kb = 32Tb

### Комментарии
750Kb/s * 86400 * 365 ~ 750 * 100 000 * 400 Kb = 30 000 000 000 Kb = 30Tb

### Реакции
40Kb/s * 86400 * 365 ~ 40 * 100 000 * 400 = 1 600 000 000 Kb = 1.6Tb

# HDD
Пропускная способность: 100 Mb/s
capacity: 32 Tb
IOPS: 100

### Посты
disks for capacity = capacity / disk_capacity = 32Tb / 32Tb = 1 disk + метаданные = 2 disks
disks for throughput = traffic_per_second / disk_throughput = 802Kb/s / 100 000Kb/s = 1 disk
disks for iops = iops / disk_iops = RPS(write+read) / disk_iops = 2300 RPS / 100 = 23 disks 

### Комментарии
disks for capacity = capacity / disk_capacity = 30 Tb / 32 Tb = 1 disk + метаданные = 2 disks
disks for throughput = traffic_per_second / disk_throughput = 900 Kb/s / 100 000 Kb/s = 1 disk
disks for iops = iops / disk_iops = RPS(write+read) / disk_iops = 3500 RPS / 100 = 35 disks

### Реакции
disks for capacity = capacity / disk_capacity = 1.6Tb / 32Tb = 1 disk
disks for throughput = traffic_per_second / disk_throughput = 40Kb/s / 100 000Kb/s = 1 disk
disks for iops = iops / disk_iops = RPS(write+read) / disk_iops = 2000 / 100 = 20 disks

Суммарно ~ 80 дисков.

# SSD
Пропускная способность: 500 Mb/s
capacity: 100Tb
IOPS: 1000

### Посты
disks for capacity = capacity / disk_capacity = 32Tb / 100Tb = 1 disk
disks for throughput = traffic_per_second / disk_throughput = 802Kb/s / 500 000Kb/s = 1 disk
disks for iops = iops / disk_iops = RPS(write+read) / disk_iops = 2300 RPS / 1000 = 3 disks 

### Комментарии
disks for capacity = capacity / disk_capacity = 30 Tb / 100 Tb = 1 disk
disks for throughput = traffic_per_second / disk_throughput = 900 Kb/s / 500 000 Kb/s = 1 disk
disks for iops = iops / disk_iops = RPS(write+read) / disk_iops = 3500 RPS / 1000 = 4 disks

### Реакции
disks for capacity = capacity / disk_capacity = 1.6Tb / 100Tb = 1 disk
disks for throughput = traffic_per_second / disk_throughput = 40Kb/s / 500 000Kb/s = 1 disk
disks for iops = iops / disk_iops = RPS(write+read) / disk_iops = 2000 / 1000 = 2 disks

Суммарно ~ 7 дисков.

```
Вывод: по расчетам количество более дешевых дисков (HDD) примерно в 10 раз больше, чем SSD дисков.
Учитывая этот факт и планируемый рост нагрузки на чтение/запись, рост количества пользователей предлагаю использовать SSD диски.
```
