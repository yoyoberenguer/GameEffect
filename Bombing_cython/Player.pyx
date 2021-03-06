try:
   from Sprites cimport Sprite
   from Sprites import Group, collide_mask, collide_rect, \
       LayeredUpdates, spritecollideany, collide_rect_ratio
except ImportError:
    raise ImportError("\nSprites.pyd missing!.Build the project first.")


try:
    cimport cython
    from cython.parallel cimport prange
    from cpython cimport PyObject_CallFunctionObjArgs, PyObject, \
        PyList_SetSlice, PyObject_HasAttr, PyObject_IsInstance, \
        PyObject_CallMethod, PyObject_CallObject
    from cpython.dict cimport PyDict_DelItem, PyDict_Clear, PyDict_GetItem, PyDict_SetItem, \
        PyDict_Values, PyDict_Keys, PyDict_Items
    from cpython.list cimport PyList_Append, PyList_GetItem, PyList_Size, PyList_SetItem
    from cpython.object cimport PyObject_SetAttr

except ImportError:
    raise ImportError("\n<cython> library is missing on your system."
          "\nTry: \n   C:\\pip install cython on a window command prompt.")

try:
    import pygame
    from pygame.math import Vector2
    from pygame import Rect, BLEND_RGB_ADD, HWACCEL
    from pygame import Surface, SRCALPHA, mask
    from pygame.transform import rotate, scale, smoothscale

except ImportError:
    raise ImportError("\n<Pygame> library is missing on your system."
          "\nTry: \n   C:\\pip install pygame on a window command prompt.")

SCREENRECT = Rect(0, 0, 800, 1024)

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
@cython.cdivision(True)
cdef class Player(Sprite):

    cdef:
        public object image, rect, mask,
        object gl
        public int _layer, life, max_life, _rotation, _blend
        float timing, dt, timer

        float reloading_time
        float timestamp, c

    def __init__(self,
                 list containers_,
                 image_,
                 int pos_x,
                 int pos_y,
                 gl_,
                 float timing_=60.0,
                 int layer_=0,
                 int _blend=0
                 ):
        """

        :param pos_x:    representing the player x position
        :param pos_y:    representing the player y position
        :param gl_:      Global variables
        :param timing_:  Sprite refreshing time
        :param layer_:   Sprite layer
        """

        Sprite.__init__(self, containers_)

        if PyObject_IsInstance(gl_.All, LayeredUpdates):
            gl_.All.change_layer(self, layer_)

        self.image     = image_
        self.rect      = image_.get_rect(center=(pos_x, pos_y))

        self.mask      = mask.from_surface(image_)
        self.gl        = gl_
        self._layer     = layer_
        self.timing    = timing_
        self.angle     = 0
        self.life      = 1000  # Player life
        self.max_life  = 1000  # Player Max life
        self._rotation = 0  # Rotation value

        if gl_.MAX_FPS > timing_:
            self.timer = self.timing
        else:
            self.timer = 0.0

    cpdef update(self, args=None):

        cdef:
            float dt    = self.dt
            object rect = self.rect
            object gl   = self.gl
            rect_clamp  = rect.clamp

        if dt > self.timer:
            rect = rect_clamp(SCREENRECT)

        dt += gl.TIME_PASSED_SECONDS
        self.dt = dt
        self.rect = rect