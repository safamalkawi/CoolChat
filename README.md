# README

This is a multiple users instant messaging web application. Fun located in that all the instant messages are translated via an API to one of three dialects (Yoda, Valley Girl and Binary Code) to make the instant messaging conversation more colorful :)

The source urls for the API dialects can be found here
http://www.degraeve.com/translator.php

Faye used for subscribe/publish.
RSpec is the used testing framework.

* Ruby version
Ruby 2.3.1p112 (2016-04-26 revision 54768)
Rails 5.0.2

* Database creation and Database initialization
No DB has been used it is just sessions

* How to run the test suite
Run $$ rake spec

* Deployment instructions
1- Clone the code then run $$ bundle install
2- Get your local server on by $$ rails server
3- Reach the login page at http://localhost:3000/login
