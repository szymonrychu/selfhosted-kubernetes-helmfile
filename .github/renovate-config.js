module.exports = {
    dryRun: false,
    username: 'szymonrichert.pl bot',
    gitAuthor: 'szymonrichert.pl bot <bot@szymonrichert.pl>',
    onboarding: false,
    platform: 'github',
    repositories: [
      'szymonrychu/containers',
    ],
    packageRules: [
      {
        description: 'lockFileMaintenance',
        matchUpdateTypes: [
          'pin',
          'digest',
          'patch',
          'minor',
          'major',
          'lockFileMaintenance',
        ],
        dependencyDashboardApproval: false,
        stabilityDays: 0,
      },
    ],
  };