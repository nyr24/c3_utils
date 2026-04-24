module std::core::dstring;

fn String DString.view(&dstring) => dstring.str_view();

<*
 @require end < dstring.len() : "Should not be more than or equal to length"
*>
fn String DString.view_range(&dstring, sz start, sz end)
{
	StringData* data = dstring.data();
	if (!data) return "";
	return (String)data.chars[start..end];
}

<*
 @require (start + len) <= dstring.len() : "Should not be more than or equal to length"
*>
fn String DString.view_range_len(&dstring, sz start, sz len)
{
	StringData* data = dstring.data();
	if (!data) return "";
	return (String)data.chars[start:len];
}

<*
 @require (start + len) <= dstring.capacity() : "Should not be more than or equal to capacity"
*>
fn String DString.view_range_len_through_cap(&dstring, sz start, sz len)
{
	StringData* data = dstring.data();
	if (!data) return "";
	return (String)data.chars[start:len];
}

<*
 @require new_len <= dstring.capacity() : "New len should be less or equal to capacity"
*>
fn void DString.resize(&dstring, sz new_len)
{
	StringData* data = dstring.data();
	data.len = new_len;
}
