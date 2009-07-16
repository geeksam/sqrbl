# Swiped from ActiveSupport 2.3.2

class Object
  def returning(value)
    yield(value)
    value
  end
end