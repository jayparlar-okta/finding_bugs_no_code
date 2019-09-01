sig Account {
  // Every Account has 0 or more Resources
  resources: set Resource,

  // Every Account has 0 or more Users
  users: set User
}

sig User {
  // Every User has direct access to 0 or more Users
  canAccess: set Resource
}

sig Resource {
  // Every Resource has 0 Parents or 1 Parent
  parent: lone Resource
}

fact "no shared users" {
  all u: User | one a: Account | u in a.users
}

fact "parent resource in same account" {
  all r: Resource | 
	some r.parent implies
		 (one a: Account | r in a.resources and r.parent in a.resources)
}

fact "no shared resources" {
   all r: Resource | one a: Account | r in a.resources
}

fact "No cycles" {
  no r: Resource |
	r in r.^parent
}

pred can_access(u: User, r: Resource) {	
       r in u.canAccess or (some r.parent and r.parent in u.canAccess)
}

run {
  some u: User, r: Resource | can_access[u, r]
}


run {} for 2 but exactly 2 Account

//if you can access the parent, you can access all its children
assert parent_implies_child {
	all u: User, r: Resource |
		can_access[u, r] implies 
                    all child: parent.r | can_access[u, child]
}


check parent_implies_child
