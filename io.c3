module std::io;

fn void File.write_all(&file, char[] buff)
{
	usz written = 0;
	while (written < buff.len)
	{
		written += file.write(buff[written..buff.len - 1])!!;
	}
}

<*
	Caller responsible for freeing return buffer with 'alloc' param
*>
fn char[] File.read_all(&file, Allocator alloc)
{
	usz file_len = file.seek(0, END)!!;
	file.seek(0, SET)!!;
	usz read = 0;

	char[] buff = allocator::alloc_array(alloc, char, file_len);
	defer catch allocator::free(alloc, buff.ptr);

	while (read < buff.len)
	{
		read += file.read(buff[read..buff.len-1])!!;
	}

	return buff;
}

fn void File.read_all_buff(&file, char[] buff)
{
	usz read = 0;
	while (read < buff.len)
	{
		read += file.read(buff[read..buff.len-1])!!;
	}
}

fn usz File.get_len(&file)
{
	usz len = file.seek(0, END)!!;
	file.seek(0, SET)!!;
	return len;
}
