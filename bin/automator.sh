#!/bin/bash

file=${BASH_SOURCE[0]}
this_dir="$(cd $(dirname $file); pwd)"
base_dir=$this_dir/../

bundle=/Users/alex/.rvm/wrappers/ruby-2.3.3/bundle

cd $base_dir
$bundle exec ruby ${base_dir}/bin/print_remote_path.rb $1 | pbcopy
