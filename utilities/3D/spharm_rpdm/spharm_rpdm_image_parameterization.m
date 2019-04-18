function [param_output] = spharm_rpdm_image_parameterization(cur_image, options)
% extract spharm from image. 
% use SPHARM-sphericial_parameterization_xr for spherical parameterization
% created: 09/14/2018 Xiongtao Ruan
% 09/17/2018 change the output as structure. 

if ~exist('options', 'var') || isempty(options)
    options = [];
end

options = ml_initparam(options, struct('verbose', false, ...
    'debug', false, ...
    'display', false, ...
    'maxDeg', 31, ...
    'z_factor', 1, ...
    'suffix', '', ...
    'OutDirectory', './temp'));


maxDeg = options.maxDeg;
OutDirectory = options.OutDirectory;
suffix = options.suffix;
z_factor = options.z_factor;

options.spharm_confs.maxDeg = maxDeg;
options.spharm_confs.savedir = OutDirectory;
options.spharm_confs.suffix = suffix;

if options.debug
    figure_dir = [OutDirectory, 'figures/'];
    mkdir(figure_dir);
end

disp('Fix topology....');
% smooth the image a little so that the paraemterization process should be better. 
se = strel('sphere', 1);
bim = imclose(cur_image > 0, se);
% bim = uint8(cur_image > 0);
origin = [0, 0, 0];
vxsize = [1, 1, z_factor];

% fix topology
tp_confs = struct();
tp_confs.Connectivity='(6+,18)'; 
tp_confs.Connectivity='(6,26)'; 
tp_confs.Epsilon = 1.5000;
inObj.bim = bim;
inObj.origin = origin;
inObj.vxsize = vxsize;
[bim, origin, vxsize] = fix_bad_topology_1(inObj, tp_confs);

[vertices, faces] =  gen_surf_data(bim,origin,vxsize);
% check whether the mesh is genus-0 mesh, if not, smooth the mesh 
if size(vertices, 1) - size(faces, 1) ~= 2
    [bim, vertices, faces] = fix_topology_by_image_processing(bim);
end

% use the one from SPHARM-spherical_optionseterization_xr
disp('Start to perform spherical optionseterization...');
special_case = ~true;
is_good = false;
is_good_1 = false;

if ~special_case
    tStart = tic;
    [sph_verts, cost_mat, is_success] = EqualAreaParametricMeshNewtonMethod(vertices, faces);
    execute_time = toc(tStart);
    [is_good, hd] = spherical_parameterization_quality_check(sph_verts, vertices, faces);

    %  if the optionseterization not successful, try to use another
    %  initialization method and redo the optimization. 
    %  use hausdorff distance to dicide use which one
    if ~is_success || ~is_good
        options_in.initialization_method = 'z_axis';
        options_in.max_iter = 1000;
        tStart_1 = tic;
        [sph_verts_1, cost_mat_1, is_success_1] = EqualAreaParametricMeshNewtonMethod(vertices, faces, [], options_in);
        execute_time_1 = toc(tStart_1);
        [is_good_1, hd_1] = spherical_parameterization_quality_check(sph_verts_1, vertices, faces);
        if is_success_1 || (~is_success_1 && hd > hd_1)
            sph_verts = sph_verts_1;
            cost_mat = cost_mat_1;
            execute_time = execute_time_1;
        end 
    end
end

is_good_2 = ~false;
hd_2 = inf;
if special_case
    hd = inf;
    hd_1 = inf;
end
% 04/09/2018
if ~is_good && ~is_good_1 && is_good_2
    % smooth the shape a bit and redo optimization.
    se_size = 1;
    se = strel('disk', se_size);
    bim_1 = imerode(bim, se);        
    bim_1 = imdilate(bim_1, se);
    bim_1 = imdilate(bim_1, se);
    bim_1 = imerode(bim_1, se);
    bim = bim_1;
    [vertices_2, faces_2] =  gen_surf_data(bim,origin,vxsize);
    % check whether the mesh is genus-0 mesh, if not, smooth the mesh 
    if size(vertices_2, 1) - size(faces_2, 1) ~= 2
        [bim, vertices_2, faces_2] = fix_topology_by_image_processing(bim);
    end
    options_in.initialization_method = 'pca';
    tStart_2 = tic;
    [sph_verts_2, cost_mat_2, is_success_2] = EqualAreaParametricMeshNewtonMethod_1(vertices_2, faces_2, [], options_in);  
    execute_time_2 = toc(tStart_2);    
    [is_good_2, hd_2] = spherical_parameterization_quality_check(sph_verts_2, vertices_2, faces_2);
    if is_success_2 || (~is_success_2 && min(hd, hd_1) > hd_2)
        vertices = vertices_2;
        faces = faces_2;
        sph_verts = sph_verts_2;
        cost_mat = cost_mat_2;
        execute_time = execute_time_2;        
    end     
end

% 06/19/2018
if ~is_good && ~is_good_1 && ~is_good_2
    % smooth the shape a bit and redo optimization.
    se_size = 1;
    se = strel('disk', se_size);
    bim_1 = imerode(bim, se);        
    bim_1 = imdilate(bim_1, se);
    bim_1 = imdilate(bim_1, se);
    bim_1 = imerode(bim_1, se);
    bim = bim_1;
    [vertices_3, faces_3] =  gen_surf_data(bim,origin,vxsize);
    % check whether the mesh is genus-0 mesh, if not, smooth the mesh 
    if size(vertices_3, 1) - size(faces_3, 1) ~= 2
        [bim, vertices_3, faces_3] = fix_topology_by_image_processing(bim);
    end
    options_in.initialization_method = 'graph_diameter';
    options_in.max_iter = 3000;
    tStart_3 = tic;
    [sph_verts_3, cost_mat_3, is_success_3] = EqualAreaParametricMeshNewtonMethod_1(vertices_3, faces_3, [], options_in);  
    execute_time_3 = toc(tStart_3);    
    [is_good_3, hd_3] = spherical_parameterization_quality_check(sph_verts_3, vertices_3, faces_3);
    if is_success_3 || (~is_success_3 && min([hd, hd_1, hd_2]) > hd_3)
        vertices = vertices_3;
        faces = faces_3;        
        sph_verts = sph_verts_3;
        cost_mat = cost_mat_3;
        execute_time = execute_time_3;        
    end     
end

maxDeg = 31;
filename = '';
[fvec, deg, Z] = create_SPHARM_des_LSF(vertices, faces, sph_verts, maxDeg, filename);


param_output = struct();
param_output.fvec = fvec;
param_output.vertices = vertices;
param_output.faces = faces;
param_output.sph_verts = sph_verts;
param_output.cost_mat = cost_mat;
param_output.execute_time = execute_time;


dpi = 150;
if false && options.debug
    figure, patch('vertices', vertices, 'faces', faces, 'FaceVertexCData',jet(size(vertices,1)),'FaceColor','interp');
    view([45, 45]);
    title(num2str(compute_id));
    figure_filename = sprintf('%soriginal_illustration_%d%s', figure_dir, compute_id);
    export_fig(figure_filename, '-opengl', '-png', '-a1', ['-r', num2str(dpi)]);
    dpi = 150;    
end

if false && options.debug
    [vs fs] = sphereMesh([0 0 0 1]);
    Zs = calculate_SPHARM_basis(vs, deg);

    Zvert = real(Zs*fvec);
    figure, patch('vertices', Zvert, 'faces', fs, 'FaceVertexCData',jet(size(vs,1)),'FaceColor','interp');
    view([45, 45]);
    title(num2str(compute_id));
    figure_filename = sprintf('%sreconst_illustration_%d%s', figure_dir, compute_id, suffix);
    export_fig(figure_filename, '-opengl', '-png', '-a1', ['-r', num2str(dpi)]);
end

if false && options.debug
    [vs, fs]=SpiralSampleSphere(4002);
    Zs = calculate_SPHARM_basis(vs, deg);
    Zvert_pdm = real(Zs*fvec);
    figure, patch('vertices', Zvert_pdm, 'faces', fs, 'FaceVertexCData',jet(size(Zvert_pdm,1)),'FaceColor','interp');
    view([45, 45]);
    title(num2str(compute_id));
    figure_filename = sprintf('%spdm_reconst_illustration_%d%s', figure_dir, compute_id, suffix);
    export_fig(figure_filename, '-opengl', '-png', '-a1', ['-r', num2str(dpi)]);
end

end
