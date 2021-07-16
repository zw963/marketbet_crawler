class ClassA
  def hello1
    raise
  ensure
    puts 'class a hello1 ensure'
  end
end

module ModuleA
  def hello1
    super
  ensure
    puts 'module a hello1 ensure'
  end
end

ClassA.prepend ModuleA

a = ClassA.new
a.hello1
