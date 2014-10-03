<?php

/* This code was copied and modified from the internet.
   Source: http://ideone.com/7mRCL# */
function cartesian($input) {
    $result = array();
 
    while (list($key, $values) = each($input)) {
        // If a sub-array is empty, it doesn't affect the cartesian product
        if (empty($values)) {
            continue;
        }
 
        // Special case: seeding the product array with the values from the first sub-array
        if (empty($result)) {
            foreach($values as $value) {
                $result[] = array($key => $value);
            }
        }
        else {
            // Second and subsequent input sub-arrays work like this:
            //   1. In each existing array inside $product, add an item with
            //      key == $key and value == first item in input sub-array
            //   2. Then, for each remaining item in current input sub-array,
            //      add a copy of each existing array inside $product with
            //      key == $key and value == first item in current input sub-array
 
            // Store all items to be added to $product here; adding them on the spot
            // inside the foreach will result in an infinite loop
            $append = array();
            foreach($result as &$product) {
                // Do step 1 above. array_shift is not the most efficient, but it
                // allows us to iterate over the rest of the items with a simple
                // foreach, making the code short and familiar.
                $product[$key] = array_shift($values);
 
                // $product is by reference (that's why the key we added above
                // will appear in the end result), so make a copy of it here
                $copy = $product;
 
                // Do step 2 above.
                foreach($values as $item) {
                    $copy[$key] = $item;
                    $append[] = $copy;
                }
 
                // Undo the side effecst of array_shift
                array_unshift($values, $product[$key]);
            }
 
            // Out of the foreach, we can add to $results now
            $result = array_merge($result, $append);
        }
    }
 
    return $result;
}

// File download
$filename = "ImgProcConf.txt";
header('Content-disposition: attachment; filename='.$filename );
header('Content-type: text/plain');

// Read form data
$input = Array(
                "bgsub" => $_POST["bgsub"]
              , "threshmeth"   => $_POST["threshmeth"]
              , "feat"  => $_POST["feat"]
              , "dimred"  => $_POST["dimred"]
              , "stat"  => $_POST["stat"]
              );
// Manipulate it properly
function set_default_if_empty(array $arr, $key, $val) {
    if ((! array_key_exists($key,$arr)) || count($arr[$key]) == 0 )
      $arr[$key] = $val;
    return $arr;
}
// Set defaults
$input = set_default_if_empty($input,"bgsub",Array("nobgsub"));
$input = set_default_if_empty($input,"threshmeth",Array("none"));
$input = set_default_if_empty($input,"feat",Array("har"));
$input = set_default_if_empty($input,"dimred",Array("none"));
$input = set_default_if_empty($input,"stat",Array("knn"));
// Do a cartesian product
$result = cartesian($input);
foreach ($result as &$r)
    $r["fv"] = array();

// Encode to JSON and send response
echo json_encode ($result);

?>
