# compare

This repository contains the files needed to compare the results between the ground truth and the results generated by running CellOrganizer locally or in Jenkins.

The steps for comparing results are

1. compare the two paths
2. compare the images in the paths
3. compare the mat files in the paths

What we need are 4 functions

* A main function of the form

```
compare_results_to_ground_truth( path1, path2 )
```

* A function of the form

```
answer = compare_paths( path1, path2 )
```

* a function that compares two images of the form

```
answer = compare_images( image_file_path1, image_file_path2 )
```

* a function that compares two Matlab structures of the form

```
answer = compare_structures( struct1, struct2 )
```

or

```
options.ignore_documentation = true;
answer = compare_structures( struct1, struct2, options )
```

The default value of `ignore_documentation` should be `false`.
