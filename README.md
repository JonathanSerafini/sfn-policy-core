# SparkleFormation Policy / Core

This gem provides the core data objects which make up the our managed SparkleFormation Policy.

## Disclaimers

> Useage of this gem and all following documentation presupposes that you are atleast minimally versed in SparkleFormation and that you have read their documentation.


> Although this stack is currently in transition, I'll strive to keep the interfaces the same. As such, minor updates to the them will keep consistent naming for dynamic and registry parameters.


> These dynamics and resources have been used in production with most earlier released versions of SparkleFormation. Although still new and realtively young, SparkleFormation has proven to be fairly stable. This gem, however, will require the current pre-release version of the 1.0.0 branch.

## Reference

*SparkleFormation upcoming docs*

https://github.com/sparkleformation/sparkle_formation/tree/1.0-updates/docs

## Introduction

This gem provides a whole slew of Dynamics ( resource macros ) and Registries ( complex properties ) with the goal of providing sane defaults when creating new resources. As much as possible, we strive to favor the same property naming conventions that CloudFormation provides so as to reduce complexity. 

## Useage

### Bootstrap

*Directory Structure*
```bash
git clone git://path/to/sfn_policy-base provision
bundle
```

### Template

To create a new template, copy templates/core/_skeleton.rb and fill in.

