module util;

macro void @swap_ptrs(#x, #y) {
	var temp = *#x;
	*#x = *#y;
	*#y = temp;
}

macro @perf(String name = "Current Test"; @body) {
	time::Time start = time::now();
	defer {
		time::Duration dur = time::now() - start;
		io::printfn("Duration of %s: %d", name, dur);
	}
	@body();
}

fn bool nullterm_str_eq(CChar* s1, CChar* s2) {
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

fn String nullterm_str_to_slice(CChar* s) {
	assert(s != null);

	usz i = 0;

	while (s[i] != '\0') {
		++i;
	}

	return (String)s[0:(i-1)];
}

fn char[] to_byte_slice(Type[] val) <Type>
{
	return ((char*)val.ptr)[:val.len * Type.sizeof];
}

fn Type[] from_byte_slice(char[] val) <Type>
{
	return ((Type*)val.ptr)[:val.len / Type.sizeof];
}

// Metaprogramming

macro unwrap_if_distinct_or_ptr_type($Type) @const
{
	$if $Type.kindof == DISTINCT || $Type.kindof == POINTER:
		return $Type.inner;
	$else
		return $Type;
	$endif
}

macro unwrap_if_distinct_type($Type) @const
{
	$if $Type.kindof == DISTINCT:
		return $Type.inner;
	$else
		return $Type;
	$endif
}

macro bool has_heap_allocated_inside($Type) @const
{
	$if is_heap_allocated($Type):
		return true;
	$endif

	$Type = unwrap_if_distinct_or_ptr_type($Type);
	$if is_heap_allocated($Type):
		return true;
	$endif

	$if types::is_indexable($Type):
		var $EntryType = get_array_inner_type($Type);
		$if has_heap_allocated_inside($EntryType):
			return true;
		$endif
	$endif

	$if is_kindof($Type, STRUCT):
		var $mems = $Type.membersof;
		$for var $i = 0; $i < $mems.len; ++$i:
			var $MemberType = $mems[$i].typeid;
			$if has_heap_allocated_inside($MemberType):
				return true;
			$endif
		$endfor
	$endif

	return false;
}

macro bool is_heap_allocated($Type) @const
{
	return $defined($Type.allocator) || $defined($Type.capacity);
}

macro bool is_primitive_type($Type) @const
{
	$Type = unwrap_if_distinct_type($Type);
	return $Type.kindof != STRUCT &&& $Type.kindof != ARRAY &&& $Type.kindof != SLICE &&& $Type.kindof != UNION &&& $Type.kindof != BITSTRUCT;
}

macro bool is_kindof($Type, TypeKind... $kinds) @const
{
	$foreach $k : $kinds:
		$if $Type.kindof == $k:
			return true;
		$endif
	$endforeach
	return false;
}

<*
	@require types::is_indexable($Type)
*>
macro get_array_inner_type($Type) @const
{
// Plain arrays
	$if is_kindof($Type, ARRAY):
		var $InnerType = $Type.inner;
		return $InnerType;
	$endif

// ElasticArray's kindof
	$if $defined($Type.entries) &&& $typeof($Type.entries) == ARRAY:
		var $EntryType = $Type.entries.inner;
		return $EntryType;
	$endif
}

macro get_innermost_type($Type) @const
{
	$if $defined($Type.inner):
		$InnerType = $Type.inner;
		return get_innermost_type($InnerType);
	$endif
	return $Type;
}

macro @get_pointee_type_val(#val) @const
{
	var $Type = $typeof(#val);
	return get_pointee_type($Type);
}

macro get_pointee_type($Type) @const
{
	$if $Type.kindof == POINTER:
		var $Inner = $Type.inner;
		return $Inner;
	$else
		return $Type;
	$endif
}

macro @deref_if_ptr(#val)
{
	var $Type = $typeof(#val);
	$if $Type.kindof == POINTER:
		return *#val;
	$else
		return #val;
	$endif
}

macro @take_address(#val)
{
	var $Type = $typeof(#val);
	$switch:
	$case is_kindof($Type, POINTER):
		return #val;
	$case is_kindof($Type, SLICE):
		return #val.ptr;
	$default:
		return &#val;
	$endswitch
}

macro char*? @get_heap_object_data_ptr(#val)
{
	$switch:
	$case $defined(#val.entries):
		return (char*)&#val.entries;
	$case $defined(#val.str_view()):
		return #val.str_view().ptr;
	$case $defined(#val.array_view()):
		return (char*)#val.array_view().ptr;
	$case $defined(#val.data()):
		return (char*)#val.data();
	$default:
		return CANT_ACCESS_DATA_PTR~;
	$endswitch
}

macro has_field($Type, String $name) @const
{
	return $defined($Type.$name);
}
