class Branches < Application
  def create(name)
    Git::Branch.create(name)
    redirect '/'
  end

  def destroy(id)
    if b = Git::Branch.by_name(id)
      b.destroy!
    end
    redirect '/'
  end

  def switch_to(id)
    if b = Git::Branch.by_name(id)
      b.checkout!
    end
    redirect '/'
  end
end
