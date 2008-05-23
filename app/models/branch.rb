module Git
  class Branch
    class << self
      def all
        if @branches.nil? || @branches.empty?
          @branches = []
          run_cmd('git branch').each_line do |line|
            selected, name = line.split(/ +/)
            name.gsub!(/\n/,'')
            @branches << Branch.new(name, selected == '*')
          end
        end
        @branches
      end

      def each(&block)
        all.each(&block)
      end

      def create(name)
        run_cmd("git branch #{name}")
        all.push(Branch.new(name, false))
      end

      def selected
        all.reject {|r| !r.selected?}[0]
      end

      def by_name(name)
        all.reject {|b| b.name != name}[0]
      end
    end

    attr_reader :selected, :name

    def initialize(name, selected)
      @name = name
      @selected = selected ? true : false
    end

    def selected?
      @selected
    end

    def destroy!
      self.class.all.clear
      run_cmd("git branch -d #{name}")
    end

    def checkout!
      self.class.all.clear
      run_cmd("git checkout #{name}")
    end
  end
end
