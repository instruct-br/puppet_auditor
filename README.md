# PuppetAuditor

PuppetAuditor is a tool to test Puppet Code against a set of defined rules.

## Installation

Install PuppetAuditor with the gem command:

```
$ gem install puppet_auditor
```

## Usage

PuppetAuditor will attempt to load rules following this hierarchy:

- Rules defined in the host `/etc/puppet_auditor.yaml`
- Rules defined in the user home `~/.puppet_auditor.yaml`
- Rules defined in the project `$(pwd)/.puppet_auditor.yaml`

The yaml file with the rules should follow this format:

```yaml
puppet_auditor_version: '1'
rules:
- name: Cant use recurse
  resource: file
  attributes:
    recurse:
      equals: true
  message: Dont use recurse => true
- name: Cant use latest
  resource: package
  attributes:
    ensure:
      equals: latest
  message: Do not use latest
```

The list of rules should declare individual rules with the following keys:

- `name`: a name for the defined rule
- `resource`: which resource should this rule verify
- `attributes`: an array of attributes that should be verified in this resource
- `message`: The message that will appear if the rule is violated

The `attributes` value should follow this structre:

```yaml
attribute:
  comparison: value
```

Where the `attribute` is a valid attribute for the valuated resource like "ensure" or "command", 
`comparison` is one of the comparison function availables like "equals" or "matches" and the
`value` is the value that will be compared using the comparison function. 

The following comparison functions are available:

- matches (regex)
- not_matches (regex)
- equals
- not_equal
- less_than
- less_or_equal_to
- greater_than
- greater_or_equal_to


For some samples check out the `spec/samples` folder.

