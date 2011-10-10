MongoMapper.connection = Mongo::Connection.new('localhost', nil, :logger => logger)

case Padrino.env
  when :development then MongoMapper.database = 'spell_development'
  when :production  then MongoMapper.database = 'spell_production'
  when :test        then MongoMapper.database = 'spell_test'
end
