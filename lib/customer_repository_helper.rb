module CustomerRepositoryHelper
  def load_repository
    @repository = load_file(filename, Customer)
  end

  def find_by_last_name(criteria)
    find_by(last_name, criteria)
  end

  def find_by_first_name(criteria)
    find_by(first_name, criteria)
  end

  def find_all_by_last_name(criteria)
    find_all_by(last_name, criteria)
  end

  def find_all_by_first_name(criteria)
    find_all_by(last_name, criteria)
  end
end
