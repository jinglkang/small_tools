PERL小技巧
---------
```perl
use strict;
use warnings;
```

## @INC:
##########
**perl中的INC变量中包含了所有的perl module的查找路径，可以使用perl -V 来查看INC的值**
### 在perl程序中修改INC， 例如：
```perl
#!/usr/bin/perl -w
push(@INC,"/home/test");
```
或者  
```perl
#!/usr/bin/perl -w
BEGIN{push(@INC,"/home/test")};
```
或者  
```perl
#!/usr/bin/perl -w
use lib '/home/test';
```

## FindBin
**让脚本在运行时找到其目录的路径，然后通过相对路径找到lib目录，解决执行时模块路径问题**
```perl
use FindBin;
```
Example:  
```perl
use FindBin qw($Bin);
use lib "$Bin/../lib";
```
**FindBin导出标量有：**  
```diff
- $Bin
path to bin directory from where script was invoked

- $Script
basename of script from which perl was invoked

- $RealBin
$Bin with all links resolved

- $RealScript
$Script with all links resolved
```


## qw()
**saving you from the tedium of having to quote and comma-separate each element of the list by hand**
```perl
my @names = qw(Kernighan Ritchie Pike); # is equal to the following
my @names = ('Kernighan', 'Ritchie', 'Pike');
```

You can use any non-alphanumeric, non-whitespace delimiter to surround the qw() string argument  
```perl
@names = qw(Kernighan Ritchie Pike);
@names = qw/Kernighan Ritchie Pike/;
@names = qw'Kernighan Ritchie Pike';
@names = qw{Kernighan Ritchie Pike};
```

```perl
#!/usr/bin/perl
use strict;
use warnings;
use File::Temp qw(tempfile tempdir);
# This code fragment has the effect of importing the tempfile and tempdir functions from the File::Temp module. 
# It does this by providing the list 'tempfile', 'tempdir' to the use function.
```
***
## perl命令行
perl -e: 让perl程序在命令行运行      
perl -n: 让perl可以一行一行处理文件     
perl -l: 自动chomp，每一个输出自动加上\n      
perl -a: 自动split放入@F     
perl -p: 让perl把下面循环添加到脚本      
$.: 文件行数     
***
## sort
-n: comparing accoring to string numberic value     
-r: reverse the result of comparisons   
***
## perl函数：quotemeta
return the values of EXPR with all the ASCII non-"word" characters backslashed (反斜杠\n).     
quotemeta (and \Q ... \E) are useful when interpolating strings into regular expressions, because by default an interpolated variable will be considered a mini-regular expression. For example:       
```perl
my $sentence = 'The quick brown fox jumped over the lazy dog';
my $substring = 'quick.*?fox';
$sentence =~ s{$substring}{big bad wolf};
```
Will cause $sentence to become 'The big bad wolf jumped over...'.      

On the other hand:
```perl
my $sentence = 'The quick brown fox jumped over the lazy dog';
my $substring = 'quick.*?fox';
$sentence =~ s{\Q$substring\E}{big bad wolf};
```
Or:
```perl
my $sentence = 'The quick brown fox jumped over the lazy dog';
my $substring = 'quick.*?fox';
my $quoted_substring = quotemeta($substring);
$sentence =~ s{$quoted_substring}{big bad wolf};
```
