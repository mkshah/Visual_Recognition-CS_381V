import numpy as np
import scipy.io as sio
import caffe
import sys

caffe.set_device(0)

model='work/04441/mkshah/files/train_val.protxt' #sys.argv[1] #'models/sun_alexnet/train_val.prototxt'
weights='work/04441/mkshah/files/ss_Alex_extra_iter_9000.caffemodel'  # sys.argv[2] #'models/sun_alexnet/cv/cv_iter_85000.caffemodel'
mean='work/04441/mkshah/files/scene_mean.binaryproto'
lmdb_dir='/work/04441/mkshah/files/scene_test_lmdb'

blob = caffe.proto.caffe_pb2.BlobProto()
data = open(mean,'rb').read()
blob.ParseFromString(data)
mean_val = np.array(caffe.io.blobproto_to_array(blob))[0]

net = caffe.Net(model, weights, caffe.TEST)


transformer = caffe.io.Transformer({'data': net.blobs['data'].data.shape})
#transformer.set_mean('data', mean_val.mean(1).mean(1))
#transformer.set_transpose('data', (2,0,1))
#transformer.set_channel_swap('data', (2,1,0))
#transformer.set_raw_scale('data', 255.0)


def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in xrange(0, len(l), n):
        yield l[i:i + n]

with open('data/val.txt','r') as f:
	test_files=f.read().strip().split('\n')

'''
test_files=[line.split(' ') for line in test_files]
test_files, targets=zip(*test_files)
targets=map(int, targets)
test_files=['data/images/SUN397_subset/%s'%f for f in test_files]
test_imgs=[caffe.io.load_image(f) for f in test_files]
test_imgs=[caffe.io.resize_image(img, (256, 256)) for img in test_imgs]
test_imgs=[transformer.preprocess('data', im) for im in test_imgs]
'''

def center_crop(img, crop_dims=(227,227)):
	return img[:,14:-15,14:-15]

import lmdb

lmdb_env = lmdb.open(lmdb_dir)
lmdb_txn = lmdb_env.begin()
lmdb_cursor = lmdb_txn.cursor()
datum = caffe.proto.caffe_pb2.Datum()

targets, test_imgs=[], []
for key, value in lmdb_cursor:
	datum.ParseFromString(value)
	label = datum.label
	data = caffe.io.datum_to_array(datum)-mean_val
	#data= transformer.preprocess('data',data)
	data=center_crop(data)
	test_imgs.append(data)
	targets.append(label)

print 'images loaded and preprocessed'

batch_size=25	
test_imgs=chunks(test_imgs, batch_size)

final_layer=[layer for layer in net.blobs.keys() if 'fc8' in layer][0]

predictions=[]
for idx, batch in enumerate(test_imgs):
	net.blobs['data'].data[...] = np.asanyarray(batch)
	net.forward()
	predictions+=np.argmax(net.blobs[final_layer].data, 1).tolist()

	print '%d/%d..'%(idx, 25)


from sklearn.metrics import confusion_matrix, accuracy_score
print accuracy_score(targets, predictions)
#print confusion_matrix(targets, predictions)


