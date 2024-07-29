############################################
#
# TCL script for Synthesis with Genus
#

############################################
# Required if SRAM blocks are synthesized
set_db hdl_max_memory_address_range 65536

############################################
# Read Sources
############################################
source ${READ_SOURCES}.tcl

############################################
# Elaborate Design
############################################

# Effort: none, low, medium, high, express
set_db syn_global_effort low

elaborate otbn

check_design -unresolved otbn 
check_design -combo_loops otbn
check_design -multiple_driver otbn

############################################
# Set Timing and Design Constraints
############################################

read_sdc /home/t_stelzer/projects/MPI/2024-pqc-opentitan/hw/ip/otbn/syn/otbn.sdc

############################################
# Apply Optimization Directives
############################################

puts "Apply Optimization Directive"

############################################
# Synthesize Design
############################################

#SYN GENERIC - Prepare Logic
syn_gen
#SYN MAP - Map Design for Target Technology
syn_map
#SYN OPT - Optimize final results
syn_opt



############################################
# Write Output Files
############################################

# REPORTS
#check_timing_intent -verbose > ../reports/timing_intent.rpt
report timing > ../reports/otbn_timing.rpt
report area > ../reports/otbn_area.rpt
report power > ../reports/otbn_power.rpt

# RESULTS

# Flat hierarchy
#ungroup -all -flatten

#write_hdl >  $TARGET_PATH/${NETLIST_NAME}_${FREQUENCY}.v
#write_sdc > ../outputs/CONSTRAINT.sdc
#write_sdf > ../outputs/SDF.sdf

quit
