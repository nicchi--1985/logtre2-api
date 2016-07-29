class Array
    def sum
        reduce(:+)
    end

    def avg
        sum.to_f / size
    end

    def vari
        reduce(0) { |a,b| a + (b - avg) ** 2 } / (size - 1)
    end

    def sd
        Math.sqrt(vari)
    end
end