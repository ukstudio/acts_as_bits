ActsAsBits
==========

ActiveRecord plugin that maintains massive flags in one column


Table Definition
================

Add "string" column into your model table.

    ALTER TABLE users ADD operations varchar(255);

Model Definition
================

    class User < ActiveRecord::Base
      acts_as_bits :operations, %w( create read update delete )
    end


Usage
=====

    user = User.new
    user.create?        # => false
    user.create = true
    user.delete = true
    user.operations     # => "1001"
    user.create?        # => true

    User.create!(:update => true, :read=>false)


Advanced
========

"(column_name)=" enables to fill up values with argument that is true/false.
This is useful for initial setting like all allow/deny.

    user = User.new
    user.operations     # => "0000"

    # set all green
    user.operations = true
    user.operations     # => "1111"

    # set all red
    user.operations = false
    user.operations     # => "0000"


Environment
===========

tested on

  * Rails 3.0.0 later


Author
======

moriq and maiha
