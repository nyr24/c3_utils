module util;

import std::time;
import std::io;

macro void swap_ptrs(#x, #y) @builtin @safemacro
{
	var temp = *#x;
	*#x = *#y;
	*#y = temp;
}

macro perf(String name = "Current Test"; @body) @builtin @safemacro
{
	time::Time start = time::now();
	defer {
		time::Duration dur = time::now() - start;
		io::printfn("Duration of %s: %d", name, dur);
	}
	@body();
}

fn bool nullterm_str_eq(CChar* s1, CChar* s2) @builtin
{
	assert(s1 != null && s2 != null);

	CChar* s1_p = s1;
	CChar* s2_p = s2;

	while ((*s1_p != '\0') && (*s2_p != '\0') && (*s1_p == *s2_p))
	{
		++s1_p;
		++s2_p;
	}

	return (*s1_p == '\0') && (*s2_p == '\0');
}

fn String nullterm_str_to_slice(CChar* s) @builtin
{
	assert(s != null);

	sz i = 0;

	while (s[i] != '\0') {
		++i;
	}

	return (String)s[0:(i-1)];
}

<*
	@require is_kindof_val(val, POINTER, SLICE) : "Should be Pointer or Slice"
*>
macro char[] to_byte_slice(val) @builtin
{
	var $Type = $typeof(val);
	var $InnerT = $Type.inner;

	$switch ($Type.kindof):
	$case POINTER:
		return ((char*)val)[:$InnerT.sizeof];
	$case SLICE:
		return ((char*)val.ptr)[:val.len * $InnerT.sizeof];
	$default:
		unreachable("Should not go here");
	$endswitch
}

<*
	@require $OutType.kindof == SLICE : "Expected be slice type as output"
*>
macro from_byte_slice(char[] val, $OutType) @builtin
{
	var $InnerT = $OutType.inner;
	return (($InnerT*)val.ptr)[:val.len / $InnerT.sizeof];
}
