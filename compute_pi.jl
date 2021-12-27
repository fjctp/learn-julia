using Printf
using Distributed

# start julia with -t T -p P with T threads and P worker processes

# added @everywhere
# without it, got an error, pi_eqn is not defined, in "numerical_integration_process"
@everywhere function pi_eqn(x)
    return 1/sqrt(1-x^2);
end

function numerical_integration_loop(y_eqn, x_range, num_slice)
    sum = 0.0;
    x_vec = LinRange(x_range[1], x_range[2], num_slice + 1);
    dx = (x_range[2] - x_range[1]) / num_slice;
    
    for i in 1:(length(x_vec)-1)
        # Trapezoidal Rule
        x1, x2 = x_vec[i], x_vec[i+1];
        y1, y2 = y_eqn(x1), y_eqn(x2);
        sum += (y1 + y2) * dx / 2;
    end
    
    return sum;
end

function numerical_integration_map(y_eqn, x_range, num_slice)
    x_vec = LinRange(x_range[1], x_range[2], num_slice + 1);
    dx = (x_range[2] - x_range[1]) / num_slice;

    y_vec = map(y_eqn, x_vec);
    terms = sum(y_vec[2:end-1]);
    return ((y_vec[1] + y_vec[end])/2.0 + terms) * dx;

    #return mapreduce(
    #    (a, b) -> (y_eqn(a) + y_eqn(b)) * dx / 2, 
    #    +, 
    #    x_vec[1:end-1], 
    #    x_vec[2:end]);
end

function numerical_integration_thread(y_eqn, x_range, num_slice)
    x_vec = LinRange(x_range[1], x_range[2], num_slice + 1);
    dx = (x_range[2] - x_range[1]) / num_slice;

    n = length(x_vec)-1;
    result = Threads.Atomic{Float64}(0.0);
    Threads.@threads for i in 1:n
        # Trapezoidal Rule
        x1, x2 = x_vec[i], x_vec[i+1];
        y1, y2 = y_eqn(x1), y_eqn(x2);
        area = (y1 + y2) * dx / 2.0;

        Threads.atomic_add!(result, area);
        #@printf("%d: %d, %.6f\n", i, Threads.threadid(), area);
    end

    return result.value;
end

function numerical_integration_process(y_eqn, x_range, num_slice)
    x_vec = LinRange(x_range[1], x_range[2], num_slice + 1);
    dx = (x_range[2] - x_range[1]) / num_slice;
    return @distributed (+) for i in 1:(length(x_vec)-1)
        # Trapezoidal Rule
        x1, x2 = x_vec[i], x_vec[i+1];
        y1, y2 = y_eqn(x1), y_eqn(x2);
        (y1 + y2) * dx / 2
    end
end

# for testing (fast)
#const gap = 1e-8;
#const num_slice = Int(1e3);

# for testing (normal 1)
#const gap = 1e-8;
#const num_slice = Int(1e6);

# for testing (normal 2)
const gap = 1e-8;
const num_slice = Int(1e8);

# for testing (slow)
#const gap = 1e-8;
#const num_slice = Int(1e9);

# for accuary (very very slow)
#const gap = 1e-10;
#const num_slice = Int(1e10);

pi_val = @time numerical_integration_loop(pi_eqn, (-1 + gap, 1 - gap), num_slice);
println(pi_val);

pi_val = @time numerical_integration_map(pi_eqn, (-1 + gap, 1 - gap), num_slice);
println(pi_val);

pi_val = @time numerical_integration_thread(pi_eqn, (-1 + gap, 1 - gap), num_slice);
println(pi_val);

pi_val = @time numerical_integration_process(pi_eqn, (-1 + gap, 1 - gap), num_slice);
println(pi_val);

## Unit Test
# find area under the curve: y = x
# const num_slice = 10;
# const pi_val = numerical_integration(x -> x, (0, 10), num_slice);
# println(pi_val); # should be 10 * 10 / 2 = 0.5

# find area under the curve: y = sqrt(1 - x^2), it is half of a circle
# const num_slice = Int(1e4);
# const pi_val = numerical_integration(x -> sqrt(1-x^2), (0, 1), num_slice);
# println(pi_val); # should be 1/4 * 1^2 * pi = 0.785398
