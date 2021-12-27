function compute_sqrt(y)
    # x = sqrt(y) ---> x^2 - y = 0
    # f(x) = x^2 - y

    function f(x)
        return x^2 - y;
    end

    threshold = 1e-8;
    max_iter = Int(1e2);

    # newton's method
    x = 0.1; # inital guess
    res = 1e6;
    for iter in 1:max_iter
        if abs(res) < threshold
            break;
        end

        slope = 2*x;
        x = x - f(x)/slope;
        res = f(x);
    end

    return x;
end

println(compute_sqrt(9.0));
println(compute_sqrt(81.0));
println(compute_sqrt(163.0));
println(compute_sqrt(169.0));
println(compute_sqrt(1e6+113));