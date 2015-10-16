## Setup

To setup this project on your local machine run:

    bundle install

and

    bundle exec rake setup

That will install the required gems and run the setup test to create the test user if it isn't already created.


## Running the tests

To run all the tests run:

    bundle exec rake test

To run just a single test, use the `rst` utility in the root of the project:

    ./rst tests/<test_file_name.rb>

.. or to run a single example in a a file:

    ./rst tests/<test_file_name.rb> <method name within that test file>


## Config for local

Right now the tests are set to run against nibley.deseretbook.com.

If you want to point at a different url, you can change the base_url method in the test_helper file.

### TODO

* Replace explicit references to input element IDs and Names with references through the associated labels.
* Centralize registered user information to one place.
* Centralize guest user information to one place.
* Centralize credit card information to one place.
* Centralize credit card form entry to one method.
* Centralize gift card form entry to one method.
* Replace the loops in the tests with individual examples (have to find a way to keep the browser open between examples).
* If we're going to merge this in to the main nibley branch, we should convert from minitest to rspec (Nibley uses rspec).
* Find a way to ensure the gift card being used always has a balance.
# Browserstack
# Browserstack
