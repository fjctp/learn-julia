# discrete fourier transform

using Plots; 

function dft(y)
    # compute discrete fourier transform of y

    # preallocate the output vector (same size as input vector)
    out = zeros(size(y)) .+ 0.0 * im;

    # loop through all the normalized frequencies
    N = length(y);
    cpow = exp(-2 * pi * im / N ); # im is imaginary axis
    for f = 1:N
        # loop through all the samples
        for i = 1:N
            area = y[i] * cpow^(i*f); # rotates y around the unit circle
                                      # inside the imagary plane
            out[f] += area; # integrate the resultant cruve
        end
    end

    return out;
end

function test_dft()
    # generate a tes signal that combine multiple sine waves
	Fs = 50; # Hz
	t = 0:1/Fs:2*pi;
	hzs = [1, 3, 5, 7, 13, 17]; # in Hz
	ws = 2*pi*hzs;
	ys = [sin.(w .* t) for w in ws];
	y = sum(ys);
	n = length(y);

    # time plot
    display(plot(t, y));

    # compute DFT
    y_dft = dft(y);
    y_dft_mag = abs.(y_dft);

    # plot aginast normalized frequeny
    normalized_hzs = (0:n-1)/n;
    display(plot(normalized_hzs, y_dft_mag));

    # plot aginast frequeny in Hz
    dft_hzs = normalized_hzs * Fs;
    display(plot(dft_hzs, y_dft_mag, xlims=(0, Fs/2)));
end

test_dft();