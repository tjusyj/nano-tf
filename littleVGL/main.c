#include    "lvgl/lvgl.h"
#include    "lv_drivers/display/fbdev.h"
#include    "lv_drivers/indev/evdev.h"
#include    "lv_examples/lv_apps/benchmark/benchmark.h"
#include    <unistd.h>

int main(void)
{
	lv_init();
	fbdev_init();

	lv_disp_drv_t disp_drv;
	lv_disp_drv_init(&disp_drv);
	disp_drv.flush_cb = fbdev_flush;
	lv_disp_drv_register(&disp_drv);

	evdev_init();
	lv_indev_drv_t indev_drv;
	lv_indev_drv_init(&indev_drv);
	indev_drv.type = LV_INDEV_TYPE_POINTER;
	indev_drv.read_cb = evdev_read;
	lv_indev_drv_register(&indev_drv);

	//lv_indev_t *mouse = lv_indev_next(NULL);
	lv_obj_t *cursor = lv_label_create(lv_scr_act(), NULL);
	lv_label_set_recolor(cursor, true);
	lv_label_set_text(cursor, "#ff0000 .cursor");
	//lv_indev_set_cursor(mouse, cursor);

	benchmark_create();

	while(1) {
	    lv_tick_inc(1);
	    lv_task_handler();
	    usleep(1);
	}

	return ;
}


