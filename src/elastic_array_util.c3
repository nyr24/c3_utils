module std::collections::elastic_array <Type, MAX_SIZE>;

import util;

<*
 @require new_cap <= MAX_SIZE : "Would exceed maximum capacity"
*>
fn void ElasticArray.resize(&arr, sz new_cap)
{
	arr.size = new_cap;
}

<*
 @require new_cap <= MAX_SIZE : "Would exceed maximum capacity"
*>
fn void ElasticArray.set_size(&arr, sz new_cap)
{
	arr.size = new_cap;
}

fn void ElasticArray.resize_to_cap(&arr)
{
	arr.size = MAX_SIZE;
}

fn Type* ElasticArray.data(&arr)
{
	return &arr.entries;
}

fn void ElasticArray.fill(&arr, Type val)
{
	foreach (&entry : arr.array_view())
	{
		*entry = val;
	}
}

fn void ElasticArray.fill_through_capacity(&arr, Type val)
{
	foreach (&entry : arr.entries)
	{
		*entry = val;
	}
}

<*
 @require ind < arr.size : "Should not exceed bounds"
*>
fn void ElasticArray.remove_unordered(&arr, sz ind)
{
	swap_ptrs(&arr[ind], &arr[arr.size - 1]);
	arr.size--;
}

<*
 @require arr.size + move_count <= arr.entries.len : "Should not exceed bounds"
*>
fn void ElasticArray.move_forward(&arr, sz move_count)
{
	arr.size += move_count;
}

<*
 @require arr.size - move_count >= 0 : "Should not exceed bounds"
*>
fn void ElasticArray.move_backward(&arr, sz move_count)
{
	arr.size -= move_count;
}

fn Type[] ElasticArray.view(&arr) => arr.array_view();

<*
 @require end < arr.size : "Should not be more than or equal to size"
*>
fn Type[] ElasticArray.view_range(&arr, sz start, sz end)
{
	return arr.entries[start..end];
}

<*
 @require (start + len) <= arr.size : "Should not be more than or equal to size"
*>
fn Type[] ElasticArray.view_range_len(&arr, sz start, sz len)
{
	return arr.entries[start:len];
}

<*
 @require (start + len) <= MAX_SIZE : "Should not be more than or equal to capacity"
*>
fn Type[] ElasticArray.view_range_len_through_cap(&arr, sz start, sz len)
{
	return arr.entries[start:len];
}
