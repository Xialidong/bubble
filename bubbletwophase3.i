[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  nz = 0
  xmax = 50
  ymax = 50
  zmax = 0
  elem_type = QUAD4
[]

[Variables]
  [./c]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = RandomIC
      min = 0.2
      max = 0.6
      variable = c
    [../]
  [../]
  [./w]
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = RandomIC
      min = 0.2
      max = 0.6
      variable = eta
    [../]
  [../]
[]

[Kernels]
  [./detadt]
    type = TimeDerivative
    variable = eta
  [../]
  [./ACBulk]
    type = AllenCahn
    variable = eta
    args = c
    f_name = F
  [../]
  [./ACInterface]
    type = ACInterface
    variable = eta
    kappa_name = kappa_eta
  [../]
  [./c_res]
    type = SplitCHParsed
    variable = c
    f_name = F
    kappa_name = kappa_c
    w = w
    args = eta
  [../]
  [./w_res]
    type = SplitCHWRes
    variable = w
    mob_name = M
  [../]
  [./time]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
[]

[BCs]
  [./Periodic]
    [./All]
      auto_direction = 'x y'
    [../]
  [../]
[]

[Materials]
  [./consts]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'L kappa_eta'
    prop_values = '1.3 0.1       '
  [../]
  [./consts2]
    type = GenericConstantMaterial
    prop_names = 'M kappa_c'
    prop_values = '1.3 0.1'
    block = 0
  [../]
  [./switching]
    type = SwitchingFunctionMaterial
    block = 0
    eta = eta
    h_order = SIMPLE
  [../]
  [./barrier]
    type = BarrierFunctionMaterial
    block = 0
    eta = eta
    g_order = SIMPLE
  [../]
  [./free_energy_A]
    type = DerivativeParsedMaterial
    block = 0
    f_name = Fa
    args = c
    function = 1.6*c+0.04*c*plog(c,0.01)+0.04*(1-c)*plog(1-c,0.01)
    derivative_order = 2
  [../]
  [./free_energy_B]
    type = DerivativeParsedMaterial
    block = 0
    f_name = Fb
    args = c
    function = 0.04*(1-c)+0.04*c*plog(c,0.01)+0.04*(1-c)*plog(1-c,0.01)
    derivative_order = 2
  [../]
  [./free_energy]
    type = DerivativeTwoPhaseMaterial
    block = 0
    fa_name = Fa
    fb_name = Fb
    args = c
    eta = eta
    outputs = exodus
    W = 27.5
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  l_max_its = 15
  l_tol = 1.0e-4
  nl_max_its = 10
  nl_rel_tol = 1.0e-11
  start_time = 0.0
  num_steps = 500
  dt = 0.001
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm 31 preonly ilu 1'
[]

[Outputs]
  exodus = true
[]

