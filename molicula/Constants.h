//
//  Constants.h
//  molicula
//
//  Created by Eric Wolter on 9/30/13.
//  Copyright (c) 2013 Eric Wolter. All rights reserved.
//

#ifndef molicula_Constants_h
#define molicula_Constants_h

#define IS_IPAD                   (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)

#define CONTROL_MIRROR_VELOCITY   (IS_IPAD ? 1.2f : 2.4f)

#define LAYOUT_DISTANCE           (IS_IPAD ? 96 : 48)

#define RENDER_HEX_HEIGHT         (IS_IPAD ? 60.0f : 30.0f)
#define RENDER_RADIUS             (RENDER_HEX_HEIGHT / 2.0f)

#define GRID_WIDTH                (7)
#define GRID_HEIGHT               (6)
#define NUMBER_OF_HOLES           (30)

#define CIRCLE_RESOLUTION         (64)
#define CIRCLE_SCALE              (0.9f)
#define CIRCLE_RADIUS             ((HEXAGON_HEIGHT / 2.0f) * CIRCLE_SCALE)

#define MOLECULE_SIZE             (5)
#define NUMBER_OF_BOND_VERTICES   (4)

#define BOND_WIDTH                (CIRCLE_RADIUS * 0.3f)

#define HEXAGON_HEIGHT            (2.0f)
#define HEXAGON_WIDTH             ((2.0f * HEXAGON_HEIGHT) / 1.732050807568877f)
#define HEXAGON_HALF_WIDTH        (HEXAGON_WIDTH / 2.0f)
#define HEXAGON_NARROW_WIDTH      (HEXAGON_HALF_WIDTH + HEXAGON_WIDTH / 4.0f)

#define M_TAU                     (M_PI * 2.0f)

#define TUTORIAL_RESOLUTION       (65)
#define TUTORIAL_ARC_RATIO        (5)
#define TUTORIAL_SCALE            (IS_IPAD ? 128 : 64)
#define ARROW_THICKNESS           (0.1f)
#define ARROW_TIP_HEIGHT          (0.1f)
#define ARROW_TIP_WIDTH           (0.2f)
#define BAR_OFFSET_Y              (0.0f)

#endif
