import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../models/itinerary_item.dart';
import '../../models/tourist_attraction_model.dart';
import '../../viewmodels/home/map_viewmodel.dart';

class MapView extends StatelessWidget {
  final String messageContent;
  final int conversationId;

  const MapView({
    Key? key,
    required this.messageContent,
    required this.conversationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel(),
      child: _MapViewContent(
        messageContent: messageContent,
        conversationId: conversationId,
      ),
    );
  }
}

class _MapViewContent extends StatefulWidget {
  final String messageContent;
  final int conversationId;

  const _MapViewContent({
    required this.messageContent,
    required this.conversationId,
  });

  @override
  State<_MapViewContent> createState() => _MapViewContentState();
}

class _MapViewContentState extends State<_MapViewContent> with TickerProviderStateMixin{
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Khởi tạo ViewModel với dữ liệu từ tin nhắn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<MapViewModel>(context, listen: false);
      viewModel.initialize(widget.messageContent, widget.conversationId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Bản đồ du lịch'),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.map), text: 'Bản đồ'),
                Tab(icon: Icon(Icons.calendar_today), text: 'Lịch trình'),
                Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () {
                  if (viewModel.currentPosition != null && viewModel.mapController != null) {
                    viewModel.mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(
                          viewModel.currentPosition!.latitude,
                          viewModel.currentPosition!.longitude,
                        ),
                        15.0,
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng chia sẻ đang được phát triển'),
                    ),
                  );
                },
              ),
            ],
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
            controller: _tabController,
            children: [
              _MapTab(viewModel: viewModel),
              _CalendarTab(viewModel: viewModel),
              _TimelineTab(viewModel: viewModel),
            ],
          ),
        );
      },
    );
  }
}

// Tab bản đồ
class _MapTab extends StatelessWidget {
  final MapViewModel viewModel;

  const _MapTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thông tin tin nhắn
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.blue.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin từ AI:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                viewModel.messageContent,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Địa điểm được phát hiện
        if (viewModel.detectedAttractions.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Địa điểm được phát hiện:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.detectedAttractions.length,
                    itemBuilder: (context, index) {
                      final attraction = viewModel.detectedAttractions[index];
                      final isSelected = viewModel.selectedAttraction?.id == attraction.id;

                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => viewModel.selectAttraction(attraction),
                          child: Chip(
                            label: Text(
                              attraction.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            backgroundColor: isSelected
                                ? Colors.green.shade600
                                : Colors.green.shade100,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        // Bản đồ Google Maps
        Expanded(
          child: GoogleMap(
            onMapCreated: viewModel.onMapCreated,
            initialCameraPosition: CameraPosition(
              target: viewModel.initialPosition,
              zoom: 12.0,
            ),
            markers: viewModel.markers,
            polylines: viewModel.polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
        ),

        // Thông tin địa điểm được chọn
        if (viewModel.selectedAttraction != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: _AttractionInfoCard(
              attraction: viewModel.selectedAttraction!,
              onAddToItinerary: () => _showAddToItineraryDialog(context, viewModel),
            ),
          ),
      ],
    );
  }

  void _showAddToItineraryDialog(BuildContext context, MapViewModel viewModel) {
    DateTime selectedDate = viewModel.selectedDate;
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Thêm vào lịch trình'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text('Ngày: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text('Giờ: ${selectedTime.format(context)}'),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  viewModel.addToItinerary(
                    viewModel.selectedAttraction!,
                    date: selectedDate,
                    time: selectedTime,
                  );
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm ${viewModel.selectedAttraction!.name} vào lịch trình'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Thêm'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Tab lịch
class _CalendarTab extends StatelessWidget {
  final MapViewModel viewModel;

  const _CalendarTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar widget
        TableCalendar<ItineraryItem>(
          firstDay: DateTime.now().subtract(const Duration(days: 30)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: viewModel.selectedDate,
          selectedDayPredicate: (day) => isSameDay(viewModel.selectedDate, day),
          eventLoader: (day) {
            final dateKey = DateTime(day.year, day.month, day.day);
            return viewModel.dailyItineraries[dateKey] ?? [];
          },
          onDaySelected: (selectedDay, focusedDay) {
            viewModel.selectDate(selectedDay);
          },
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            markerDecoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.green.shade600,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.orange.shade600,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),

        const Divider(),

        // Danh sách lịch trình trong ngày
        Expanded(
          child: viewModel.todayItinerary.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có lịch trình cho ngày này',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thêm địa điểm từ tab Bản đồ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
              : ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.todayItinerary.length,
            onReorder: viewModel.reorderItinerary,
            itemBuilder: (context, index) {
              final item = viewModel.todayItinerary[index];
              return _ItineraryItemCard(
                key: ValueKey(item.attraction.id),
                item: item,
                index: index,
                onRemove: () => viewModel.removeFromItinerary(item),
                onEdit: () => _showEditItineraryDialog(context, viewModel, item),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEditItineraryDialog(BuildContext context, MapViewModel viewModel, ItineraryItem item) {
    DateTime selectedDate = item.visitTime;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(item.visitTime);
    Duration selectedDuration = item.estimatedDuration;
    String notes = item.notes;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Chỉnh sửa lịch trình'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text('Ngày: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text('Giờ: ${selectedTime.format(context)}'),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setState(() {
                          selectedTime = time;
                        });
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: Text('Thời gian dự kiến: ${selectedDuration.inHours}h ${selectedDuration.inMinutes % 60}m'),
                    onTap: () {
                      // Show duration picker
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Chọn thời gian'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('1 giờ'),
                                onTap: () {
                                  setState(() {
                                    selectedDuration = const Duration(hours: 1);
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text('2 giờ'),
                                onTap: () {
                                  setState(() {
                                    selectedDuration = const Duration(hours: 2);
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text('3 giờ'),
                                onTap: () {
                                  setState(() {
                                    selectedDuration = const Duration(hours: 3);
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text('Cả ngày'),
                                onTap: () {
                                  setState(() {
                                    selectedDuration = const Duration(hours: 8);
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú',
                      hintText: 'Thêm ghi chú cho địa điểm này...',
                    ),
                    maxLines: 3,
                    onChanged: (value) => notes = value,
                    controller: TextEditingController(text: notes),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newItem = item.copyWith(
                    visitTime: DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    ),
                    estimatedDuration: selectedDuration,
                    notes: notes,
                  );
                  viewModel.updateItineraryItem(item, newItem);
                  Navigator.pop(dialogContext);
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Tab timeline
class _TimelineTab extends StatelessWidget {
  final MapViewModel viewModel;

  const _TimelineTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date selector
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 8),
              Text(
                'Lịch trình ngày ${viewModel.selectedDate.day}/${viewModel.selectedDate.month}/${viewModel.selectedDate.year}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: viewModel.selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    viewModel.selectDate(date);
                  }
                },
                icon: const Icon(Icons.edit_calendar),
              ),
            ],
          ),
        ),

        const Divider(),

        // Timeline
        Expanded(
          child: viewModel.todayItinerary.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timeline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có lịch trình cho ngày này',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.todayItinerary.length,
            itemBuilder: (context, index) {
              final item = viewModel.todayItinerary[index];
              final isFirst = index == 0;
              final isLast = index == viewModel.todayItinerary.length - 1;

              return TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.2,
                isFirst: isFirst,
                isLast: isLast,
                indicatorStyle: IndicatorStyle(
                  width: 30,
                  height: 30,
                  indicator: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                beforeLineStyle: LineStyle(
                  color: Colors.blue.shade300,
                  thickness: 2,
                ),
                afterLineStyle: LineStyle(
                  color: Colors.blue.shade300,
                  thickness: 2,
                ),
                endChild: _TimelineItemCard(item: item),
                startChild: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        TimeOfDay.fromDateTime(item.visitTime).format(context),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      Text(
                        '${item.estimatedDuration.inHours}h ${item.estimatedDuration.inMinutes % 60}m',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Action buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Quay lại chat'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: viewModel.todayItinerary.isEmpty
                      ? null
                      : () async {
                    final success = await viewModel.saveItinerary();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lịch trình đã được lưu'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Lưu lịch trình'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget hiển thị thông tin địa điểm
class _AttractionInfoCard extends StatelessWidget {
  final TouristAttraction attraction;
  final VoidCallback onAddToItinerary;

  const _AttractionInfoCard({
    required this.attraction,
    required this.onAddToItinerary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            attraction.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                attraction.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                attraction.address,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Text(
                    ' ${attraction.rating}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: onAddToItinerary,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 36),
          ),
          child: const Text('Thêm', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}

// Widget item trong lịch trình
class _ItineraryItemCard extends StatelessWidget {
  final ItineraryItem item;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  const _ItineraryItemCard({
    Key? key,
    required this.item,
    required this.index,
    required this.onRemove,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade600,
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(item.attraction.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${TimeOfDay.fromDateTime(item.visitTime).format(context)} - ${item.estimatedDuration.inHours}h ${item.estimatedDuration.inMinutes % 60}m',
              style: const TextStyle(fontSize: 12),
            ),
            if (item.notes.isNotEmpty)
              Text(
                item.notes,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 20),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }
}

// Widget item trong timeline
class _TimelineItemCard extends StatelessWidget {
  final ItineraryItem item;

  const _TimelineItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 16, bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TimeOfDay.fromDateTime(item.visitTime).format(context),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.attraction.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Dự kiến: ${item.estimatedDuration.inHours}h ${item.estimatedDuration.inMinutes % 60}m',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            if (item.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.notes,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
