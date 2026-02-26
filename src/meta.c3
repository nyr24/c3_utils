module util;

// Metaprogramming utils

macro bool is_heap_allocated($Type) @const @builtin
{
	return $defined($Type.allocator) || $defined($Type.capacity);
}

macro bool is_kindof($Type, TypeKind... $kinds) @const @builtin
{
	$foreach $k : $kinds:
		$if $Type.kindof == $k:
			return true;
		$endif
	$endforeach
	return false;
}

macro bool is_kindof_val(#val, TypeKind... $kinds) @const @builtin @safemacro
{
	return is_kindof($typeof(#val), ...$kinds);
}

macro inner_type_if_kindof($Type, TypeKind... $kinds) @const @builtin
{
	$if is_kindof($Type):
		return $Type.inner;
	$else
		return $Type;
	$endif
}

macro bool is_primitive_type($Type) @const @builtin
{
	$Type = inner_type_if_kindof($Type, TYPEDEF);
	return !is_kindof($Type, STRUCT, UNION, SLICE, ARRAY, BITSTRUCT);
}

macro bool is_array_like($Type) @const @builtin
{
	$Type = inner_type_if_kindof($Type, TYPEDEF);
	return is_kindof($Type, ARRAY, SLICE);
}

macro bool is_array_like_val(#val) @const @builtin @safemacro
{
	return is_array_like($typeof(#val));
}

macro bool is_ptr_to_ptr(#val) @const @builtin @safemacro
{
	var $Type = $typeof(#val);
	return $Type.kindof == POINTER &&& $Type.inner.kindof == POINTER;
}

macro innermost_type($Type) @const @builtin
{
	var $InnerType = $Type;
	$if $defined($Type.inner):
		$InnerType = $Type.inner;
		return innermost_type($InnerType);
	$endif
	return $InnerType;
}

macro innermost_type_val(#val) @const @builtin @safemacro
{
	return innermost_type($typeof(#val));
}

macro pointee_type($Type) @const @builtin
{
	$switch ($Type.kindof):
	$case POINTER:
		var $Inner = $Type.inner;
		return $Inner;
	$default:
		return $Type;
	$endswitch
}

macro pointee_type_val(#val) @const @builtin @safemacro
{
	var $Type = $typeof(#val);
	return pointee_type($Type);
}

macro deref_if_ptr(#val) @builtin @safemacro
{
	var $Type = $typeof(#val);
	$if $Type.kindof == POINTER:
		return *#val;
	$else
		return #val;
	$endif
}

macro deref_if_ptr_to_ptr(#val) @builtin @safemacro
{
	var $Type = $typeof(#val);
	$if is_ptr_to_ptr($Type):
		return *#val;
	$else
		return #val;
	$endif
}

macro take_address(#val) @builtin @safemacro
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

macro has_field($Type, String $name) @const @builtin @safemacro
{
	return $defined($Type.$name);
}
