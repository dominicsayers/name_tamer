# encoding: utf-8
require 'csv'

desc 'Build prefixes and suffixes'
  task :adfixes do
    pp = []
    po = []
    sp = []
    so = []

    CSV.foreach("#{File.dirname(__FILE__)}/prefixes.csv", headers:true) do |row|
      if row[2] == 'person'
        pp << row[0]
      else
        po << row[0]
      end
    end

    CSV.foreach("#{File.dirname(__FILE__)}/suffixes.csv", headers:true) do |row|
      if row[2] == 'person'
        sp << row[0]
      else
        so << row[0]
      end
    end

    puts "'" + pp.join("', '") + "'"
    puts "'" + po.join("', '") + "'"
    puts "'" + sp.join("', '") + "'"
    puts "'" + so.join("', '") + "'"
  end
