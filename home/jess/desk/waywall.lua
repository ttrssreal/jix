local waywall = require("waywall")
local helpers = require("waywall.helpers")

local NORMAL_SENSITIVITY = 32.28912797;

local EYE_MEASURE_RES = { x = 384, y = 16384 }
local PLANAR_FOG_ABUSE_RES = { x = 1920, y = 300 }
local FIND_BASTION_RES = { x = 340, y = 1080 }
local EYE_SRC_WIDTH = 30;
local EYE_SRC_HEIGHT = 580;

local EYE_SRC = {
  x = (EYE_MEASURE_RES.x - EYE_SRC_WIDTH) / 2,
  y = (EYE_MEASURE_RES.y - EYE_SRC_HEIGHT) / 2,
  w = EYE_SRC_WIDTH,
  h = EYE_SRC_HEIGHT,
};

local EYE_DST = {
  x = 0,
  y = 0,
  w = 700,
  h = 400,
};

local toggle_eye_measure_res_fn = helpers.toggle_res(EYE_MEASURE_RES.x, EYE_MEASURE_RES.y, 0.1)
local toggle_planar_fog_abuse_res_fn = helpers.toggle_res(PLANAR_FOG_ABUSE_RES.x, PLANAR_FOG_ABUSE_RES.y)
local toggle_find_bastion_res_fn = helpers.toggle_res(FIND_BASTION_RES.x, FIND_BASTION_RES.y)

helpers.res_mirror({ src = EYE_SRC, dst = EYE_DST, }, EYE_MEASURE_RES.x, EYE_MEASURE_RES.y)
helpers.res_image("/home/jess/.config/waywall/overlay.png", {
  dst = EYE_DST
}, EYE_MEASURE_RES.x, EYE_MEASURE_RES.y)

local config = {
  input = {
    sensitivity = NORMAL_SENSITIVITY,
  },
  theme = {
    background = "#303030ff",
    ninb_anchor = {
      position = "topright",
      y = 130,
      x = -10,
    },
    ninb_opacity = 0.7,
  },
}

config.actions = {
  ["Ctrl-Shift-N"] = function()
    waywall.exec("@ninjabrain-bot@")
    waywall.show_floating(true)
  end,
  ["F4"] = function()
    toggle_eye_measure_res_fn()
  end,
  ["grave"] = function()
    toggle_find_bastion_res_fn()
  end,
  ["F6"] = function()
    toggle_planar_fog_abuse_res_fn()
  end,
}

return config
