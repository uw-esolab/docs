import pyomo.environ as pyomo
import random 
import matplotlib.pyplot as plt

# Create a model
model = pyomo.ConcreteModel()

# Time series
model.nt = pyomo.Param(initialize = 20000)
model.T = pyomo.Set(initialize = range(model.nt()))

# Create some random input data
xtmp = {}
random.seed(123)
for t in range(model.nt()):
    xtmp[t] = random.uniform(0,100)

# Assign parameter values
model.X_in = pyomo.Param(model.T, initialize=xtmp)
model.XM = pyomo.Param(initialize=max(xtmp.values()))
model.X0 = pyomo.Param(initialize=50)

# setup an array of continuous and binary variables over the time domain
model.x = pyomo.Var(model.T, domain=pyomo.NonNegativeReals)
model.y = pyomo.Var(model.T, domain=pyomo.Binary)

# Maximize x 
def f_objective(model):
    return sum([model.x[t] for t in model.T])
model.objective = pyomo.Objective(rule = f_objective, sense = pyomo.maximize)

# ---Add some constraints

# x[t] less than X_in for all t
def f_x_lim(model, t):
    return model.x[t] <= model.X_in[t]
model.c_x_lim = pyomo.Constraint(model.T, rule = f_x_lim)

# x[t] is limited by value of binary y[t]
def f_x_y(model, t):
    return model.x[t] <= model.XM()*model.y[t]
model.c_x_y = pyomo.Constraint(model.T, rule = f_x_y)

# y[t] can only be 1 when X_in[t] > X0
def f_y_x0(model, t):
    return model.y[t] <= model.X_in[t] / model.X0
model.c_y_x0 = pyomo.Constraint(model.T, rule = f_y_x0)

def n_active(model):
    return sum(model.y[:]) <= 100
model.c_n_active = pyomo.Constraint(rule = n_active)

# ------ solve and print out results
#solver setup
#solver = pyomo.SolverFactory('glpk')
solver = pyomo.SolverFactory('cbc')
solver.options['sec'] = 5
# solver.options['threads'] = 4
# res = solver.solve(model, options={"sec":15}, tee=True)
res = solver.solve(model, tee=True)

print(res)
print(model.objective())

# Space-separated list of variables to print
pouts = "X_in x y".split()

# Automatically handle printing
print('t\t'+'\t'.join(pouts))

for t in model.T:
    fmt = "{:d}" + "\t{:.1f}"*(len(pouts))
    outs = []
    for o in pouts:
        try:
            outs.append(model.__getattribute__(o)[t]() )
        except:
            outs.append(model.__getattribute__(o)[t] )
    # print( fmt.format(*([t]+outs)) )

plt.plot(\
    [mt for mt in model.T], [mx for mx in model.X_in.values()], \
    [mt for mt in model.T], [mx() for mx in model.x.values()], \
    [0, model.nt()], [model.X0(), model.X0()], 'r--')
plt.show()