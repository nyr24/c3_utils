import util;
import std::io;
import std::collections::list;
import std::collections::map;

fn void accept_by_val(int v)
{
	io::printn(v);
}

fn void accept_by_ptr(int* v)
{
	io::printn(v);
}

struct Simple
{
	int field1;
}

fn void main_test() @test
{
	int n = 228;
	int* n_p = &n;
	int** n_pp = &n_p;
	int[*] arr = {1,2,3,4,5};
	int[] slice = arr[:arr.len];
	List{int} list;
	DString dstr;
	HashMap{int, int} map;

	test::@check(innermost_type_val(n_pp) == int);
	test::@check(innermost_type($typeof(n_pp)) == int);
	test::@check(is_ptr_to_ptr(n_pp));

	accept_by_ptr(take_address(n));
	accept_by_ptr(take_address(n_p));

	accept_by_val(deref_if_ptr(n));
	accept_by_val(deref_if_ptr(n_p));

	test::@check(pointee_type_val(n_p) == int);
	test::@check(pointee_type($typeof(n_p)) == int);

	test::@check(is_array_like_val(arr));
	test::@check(is_array_like_val(slice));

	test::@check(has_field(Simple, "field1"));
	test::@check(!has_field(Simple, "field2"));
}
