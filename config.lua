Config = Config or {}

Config.MaxFrequency = 500

Config.CanJoinFrequentie = true

Config.RestrictedChannels = {
  [1] = {
    police = true,
    sheriff = false,
    ambulance = true,
  },
  [2] = {
    police = true,
    sheriff = false,
    ambulance = true,
  },
  [3] = {
    police = true,
    sheriff = false,
    ambulance = true,
  },
  [4] = {
    police = true,
    sheriff = false,
    ambulance = true,
  },
  [5] = {
    police = true,
    sheriff = false,
    ambulance = true,
  },
  [6] = {
    police = true,
    sheriff = false,
    ambulance = true,
  },
  [7] = {
    police = true,
    sheriff = false,
    ambulance = true,
  },
  [8] = {
    police = true,
    sheriff = false,
    ambulance = true,
  },
  [9] = {
    police = true,
    sheriff = false,
    ambulance = true,
  },
  [10] = {
    police = true,
    sheriff = false,
    ambulance = true,
  },
  [11] = {
    police = false,
    sheriff = true,
    ambulance = false,
  },
  [12] = {
    police = false,
    sheriff = true,
    ambulance = false,
  },
  [13] = {
    police = false,
    sheriff = true,
    ambulance = false,
  },
  [14] = {
    police = false,
    sheriff = true,
    ambulance = false,
  },
  [15] = {
    police = false,
    sheriff = true,
    ambulance = false,
  },
  [16] = {
    police = false,
    sheriff = true,
    ambulance = false,
  },
  [17] = {
    police = false,
    sheriff = true,
    ambulance = false,
  },
  [18] = {
    police = false,
    sheriff = true,
    ambulance = false,
  },
  [19] = {
    police = false,
    sheriff = true,
    ambulance = false,
  },
  [20] = {
    police = false,
    sheriff = true,
    ambulance = false,
  },
} 



Config.messages = {
  ["not_on_radio"] = "You're not connected to a signal",
  ["on_radio"] = "You're already connected to this signal",
  ["joined_to_radio"] = "You're connected to: ",
  ["restricted_channel_error"] = "You can not connect to this signal!",
  ["invalid_radio"] = "This frequency is not available.",
  ["you_on_radio"] = "You're already connected to this channel",
  ["you_leave"] = "You left the channel.",
  ['volume_radio'] = 'New volume ',
  ['decrease_radio_volume'] = 'The radio is already set to maximum volume',
  ['increase_radio_volume'] = 'The radio is already set to the lowest volume',
  ['increase_decrease_radio_channel'] = 'New channel ',
}
