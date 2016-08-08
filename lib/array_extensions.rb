class Array
    def sum
        reduce(:+)
    end

    def avg
        sum.to_f / size
    end

    def vari
        av = avg
        reduce(0) { |a,b| a + (b - av) ** 2 } / (size - 1)
    end

    def sd
        Math.sqrt(vari)
    end
end