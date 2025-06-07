Table users {
  id integer [primary key]
  first_name varchar
  last_name varchar
  role varchar
  created_at timestamp
}

Table posts {
  id integer [primary key]
  title varchar
  body text [note: 'Content of the post']
  user_id integer [not null]
  status varchar
  comments integer
  place_id integer
  created_at timestamp
}

Table comments {
  id integer [primary key]
  post_id integer
  text varchar
  created_at timestamp
}

Table subscribers {
  id integer [primary key]
  subscriber_user_id integer
  user_id integer // на кого подписан subscriber_user_id
  created_at timestamp
}

Table places {
  id integer [primary key]
  name string
  location point
  post_count int [default: 0]
}

Table reactions {
  id integer [primary key]
  user_id integer
  post_id integer
  type bool
}

Ref user_posts: posts.user_id > users.id // many-to-one
Ref comments_posts: comments.post_id > posts.id
Ref: reactions.user_id > users.id
Ref: reactions.post_id > posts.id
Ref: posts.place_id - places.id
Ref: users.id < subscribers.user_id
Ref: users.id < subscribers.subscriber_user_id
