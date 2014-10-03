function [r_image] = ml_bmpread(p_path)
  
  file_id = fopen(p_path, 'rb'); 
  magic_number = fread(file_id, 2, 'uchar=>char')';
  if (~strcmp(magic_number, 'BM'))
    error('Unknown file format'); 
  end
  file_size = fread(file_id, 1, 'uint32'); 
  fread(file_id, 1, 'uint16'); 
  fread(file_id, 1, 'uint16'); 
  data_offset = fread(file_id, 1, 'uint32'); 
  header_size = fread(file_id, 1, 'uint32'); 
  width = fread(file_id, 1, 'int32'); 
  height = fread(file_id, 1, 'int32'); 
  planes = fread(file_id, 1, 'uint16'); 
  bits_per_pixel = fread(file_id, 1, 'uint16'); 
  compression = fread(file_id, 1, 'uint32'); 
  image_size = fread(file_id, 1, 'uint32'); 
  horizontal_resolution = fread(file_id, 1, 'int32'); 
  vertical_resolution = fread(file_id, 1, 'int32'); 
  colors = fread(file_id, 1, 'uint32'); 
  important_colors = fread(file_id, 1, 'uint32'); 
  
  if (header_size ~= 40)
    error('Header size is not 40'); 
  end
  if (bits_per_pixel ~= 8 && bits_per_pixel ~= 16)
    error('Bits per pixel is not 8 or 16'); 
  end
  if (image_size == 0)
    image_size = file_size - data_offset; 
  end
  
  
  fseek(file_id, data_offset, -1); 

  datatype = ['uint' num2str(bits_per_pixel)]; 
  r_image = zeros(abs(height), width, datatype);
  row_bytes = image_size / abs(height); 
  for row_index = 1: abs(height)
    row_data = fread(file_id, width, ...
                     datatype);
    padding_data = fread(file_id, row_bytes - width * bits_per_pixel ...
                         / 8, 'uint8'); 
    r_image(abs(height) - row_index + 1, : )=row_data(1: width); 
  end
  if (height < 0)
    r_image = flip(r_image, 1); 
  end
  
  fclose(file_id);
