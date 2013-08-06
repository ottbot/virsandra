# Virsandra [![Build Status](https://travis-ci.org/ottbot/virsandra.png)](https://travis-ci.org/ottbot/virsandra) [![Code Climate](https://codeclimate.com/github/ottbot/virsandra.png)](https://codeclimate.com/github/ottbot/virsandra) [![Dependency Status](https://gemnasium.com/ottbot/virsandra.png)](https://gemnasium.com/ottbot/virsandra) [![Coverage Status](https://coveralls.io/repos/ottbot/virsandra/badge.png?branch=master)](https://coveralls.io/r/ottbot/virsandra)

The Cassandra backed models with Virtus gem with a stupid name.

## Moving target

Virsandra is meant to make it easy to use cassandra for persistence
for models build with virtus.

The feature set will likely remain simple, the idea is to not block
development of other projects while the implementation of CQL changes
quickly.

## Schema yourself

At this stage, you're on your own in terms of schema management. The
gem expects you to maintain table <=> model attribute mappings
yourself.

## Example usage

````ruby
require 'virsandra'

Virsandra.configure |c|
  c.servers = "127.0.0.1:9160"
  c.keyspace = "example_keyspace"
end
````

To define a `Company` model backed by a table `companies` using a composite primary key of `name text, founder text`:
````ruby
class Company
  include Virsandra::Model

  attribute :name, String
  attribute :founder, String
  attribute :turnover, Fixnum
  attribute :founded, Date

  table :companies
  key :name, :founder
end
````

Create a company:
````ruby
company = Company.new(name: "Gooble",
                      founder: "Larry Brin",
                      turnover: 2000000,
                      founded: 1884)
company.save
````

Find the company by key:
````ruby
company = Company.find(name: "Gooble", founder: "Larry Brin")
````

Find or initialize a company. If there is a row with the same primary
key, this will load missing attributes from cassandra and merge new
ones.

````ruby
company = Company.load(name: "Gooble", founder: "Larry Brin", foundec: 2012)
company.attributes
#=> {name: "Gooble", founder: "Larry Brin", turnover: 2000000, founded: 2012}
````

Search for companies:
````ruby
companies = Companies.all

googbles = Companies.where(name: 'Gooble')

company_names = Companies.all.map(&:name)
````

## TODO / Missing
1. Support for Set, List, and Map column types
1. Schema creation / migration
1. Model DSL method chaining
1. Update one or more rows
1. Secondary indices
1. Model attributes that are not Cassandra columns
1. Counters (invalid ?)




## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
