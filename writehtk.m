function writehtk(file,d,fp,tc)
%WRITEHTK write data in HTK format []=writehtk(file,d,fp,tc)
%
% Inputs:
%    file = name of file to write (no default extension)
%       d = data to write: one column per frame
%      fp = frame period in seconds
%      tc = type code = the sum of a data type and (optionally) one or more of the listed modifiers
%             0  WAVEFORM     Acoustic waveform
%             1  LPC          Linear prediction coefficients
%             2  LPREFC       LPC Reflection coefficients:  -lpcar2rf([1 LPC]);LPREFC(1)=[];
%             3  LPCEPSTRA    LPC Cepstral coefficients
%             4  LPDELCEP     LPC cepstral+delta coefficients (obsolete)
%             5  IREFC        LPC Reflection coefficients (16 bit fixed point)
%             6  MFCC         Mel frequency cepstral coefficients
%             7  FBANK        Log Fliter bank energies
%             8  MELSPEC      linear Mel-scaled spectrum
%             9  USER         User defined features
%            10  DISCRETE     Vector quantised codebook
%            11  PLP          Perceptual Linear prediction
%            12  ANON
%            64  _E  Includes energy terms                  hd(1)
%           128  _N  Suppress absolute energy               hd(2)
%           256  _D  Include delta coefs                    hd(3)
%           512  _A  Include acceleration coefs             hd(4)
%          1024  _C  Compressed                             hd(5)
%          2048  _Z  Zero mean static coefs                 hd(6)
%          4096  _K  CRC checksum (not implemented yet)     hd(7) (ignored)
%          8192  _0  Include 0'th cepstral coef             hd(8)
%         16384  _V  Attach VQ index                        hd(9)
%         32768  _T  Attach delta-delta-delta index         hd(10)

% http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html

% Copyright (C) Masayuki Suzuki
% GAVORIN is a toolbox for speech processing.

dir = fileparts(file); if ~ exist(dir, 'dir'); mkdir(dir); end
fid=fopen(file,'w','b');
if fid < 0; error( sprintf('Cannot write to %s', file) ); end
tc=bitset(tc,13,0);                 % silently ignore a checksum request

[nv,nf]=size(d);
nhb=10;                             % number of suffix codes
ndt=6;                              % number of bits for base type
hb=floor(tc*pow2(-(ndt+nhb):-ndt));
hd=hb(nhb+1:-1:2)-2*hb(nhb:-1:1);   % extract bits from type code
dt=tc-pow2(hb(end),ndt);            % low six bits of tc represent data type
tc=tc-65536*(tc>32767);

if hd(5)                            % if compressed
    error('Do not support Compressed option');
end
fwrite(fid,nf,'long');              % write frame count
fwrite(fid,round(fp*1.E7),'long');  % write frame period (in 100 ns units)
if any(dt==[0,5,10])                % write data as shorts
    if dt==5                        % IREFC has fixed scale factor
        d=d*32767;
    end
    nby=nv*2;
    if nby<=32767
        fwrite(fid,nby,'short');    % write byte count
        fwrite(fid,tc,'short');     % write type code
        fwrite(fid,d,'short');      % write data array
    end
else
    nby=nv*4;
    if nby<=32767
        fwrite(fid,nby,'short');    % write byte count
        fwrite(fid,tc,'short');     % write type code
        fwrite(fid,d,'float');      % write data array
    end
end
fclose(fid);
if nby>32767
    delete(file);                   % remove file if byte count is rubbish
    error(sprintf('byte count of frame is %d which exceeds 32767 (is data transposed?)',nby));
end
